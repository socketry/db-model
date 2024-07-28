# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2021, by Samuel Williams.

require_relative 'literal'

module DB
	module Model
		module Statement
			module Predicate
				class Empty
					def append_to(statement)
						statement.literal(true)
					end
					
					def + other
						other
					end
					
					def eql?(other)
						self.class.eql?(other.class)
					end
					
					def hash
						self.class.hash
					end
				end
				
				EMPTY = Empty.new
				
				class Between
					def initialize(key, minimum, maximum)
						@key = key
						@minimum = minimum
						@maximum = maximum
					end
					
					attr :key
					attr :minimum
					attr :maximum
					
					def append_to(statement)
						@key.append_to(statement)
						statement.clause("BETWEEN")
						@minimum.append_to(statement)
						statement.clause("AND")
						@maximum.append_to(statement)
					end
					
					def eql?(other)
						self.class.eql?(other.class) && self.key.eql?(other.key) && self.minimum.eql?(other.minimum) && self.maximum.eql?(other.maximum)
					end
					
					def hash
						[self.class, @key, @minimum, @maximum].hash
					end
				end
				
				class Binary
					def initialize(key, operator, value)
						@key = key
						@operator = operator
						@value = value
					end
					
					attr :key
					attr :operator
					attr :value
					
					def append_to(statement)
						@key.append_to(statement)
						statement.clause(@operator)
						@value.append_to(statement)
					end
					
					def eql?(other)
						self.class.eql?(other.class) && self.key.eql?(other.key) && self.operator.eql?(other.operator) && self.value.eql?(other.value)
					end
					
					def hash
						[self.class, @key, @operator, @value].hash
					end
				end
				
				class Null
					def initialize(key)
						@key = key
					end
					
					attr :key
					
					def append_to(statement)
						@key.append_to(statement)
						statement.clause("IS NULL")
					end
					
					def eql?(other)
						self.class.eql?(other.class) && self.key.eql?(other.key)
					end
					
					def hash
						[self.class, @key].hash
					end
				end
				
				class Composite
					def self.for(predicates)
						if predicates.size == 0
							return EMPTY
						else
							return self.new(predicates)
						end
					end
					
					def initialize(predicates, operator = "AND")
						@predicates = predicates
						@operator = operator
					end
					
					attr :predicates
					attr :operator
					
					def append_to(statement)
						first = true
						
						statement.clause("(")
						
						@predicates.each_with_index do |predicate, index|
							statement.clause(@operator) unless first
							first = false
							
							predicate.append_to(statement)
						end
						
						statement.clause(")")
					end
					
					def + other
						Composite.new([self, other])
					end
					
					def & other
						Composite.new([self, other], "AND")
					end
					
					def | other
						Composite.new([self, other], "OR")
					end
					
					def eql?(other)
						self.class.eql?(other.class) && self.predicates.eql?(other.predicates)
					end
					
					def hash
						[self.class, @predicates, @operator].hash
					end
				end
				
				def self.coerce(key, value)
					case value
					when Array
						Binary.new(key, "IN", Tuple.new(value))
					when Range
						if value.min.nil?
							if value.exclude_end?
								Binary.new(key, "<", Literal.new(value.max))
							else
								Binary.new(key, "<=", Literal.new(value.max))
							end
						elsif value.max.nil?
							if value.exclude_end?
								Binary.new(key, ">", Literal.new(value.max))
							else
								Binary.new(key, ">=", Literal.new(value.max))
							end
						else
							if value.exclude_end?
								Composite.new([
									Binary.new(key, ">", Literal.new(value.min)),
									Binary.new(key, "<", Literal.new(value.max))
								])
							else
								Between.new(key, Literal.new(value.min), Literal.new(value.max))
							end
						end
					when nil
						Null.new(key)
					else
						Binary.new(key, "=", Literal.new(value))
					end
				end
				
				def self.where(*arguments, **options, &block)
					Composite.for(
						options.map do |key, value|
							coerce(Identifier.coerce(key), value)
						end
					)
				end
			end
		end
	end
end
