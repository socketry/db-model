# frozen_string_literal: true

# Copyright, 2021, by Samuel G. D. Williams. <http://www.codeotaku.com>
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.

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
				end
				
				EMPTY = Empty.new
				
				class Between
					def initialize(key, minimum, maximum)
						@key = key
						@minimum = minimum
						@maximum = maximum
					end
					
					def append_to(statement)
						@key.append_to(statement)
						statement.clause("BETWEEN")
						@minimum.append_to(statement)
						statement.clause("AND")
						@maximum.append_to(statement)
					end
				end
				
				class Binary
					def initialize(key, operator, value)
						@key = key
						@operator = operator
						@value = value
					end
					
					def append_to(statement)
						@key.append_to(statement)
						statement.clause(@operator)
						@value.append_to(statement)
					end
				end
				
				class Null
					def initialize(key)
						@key = key
					end
					
					def append_to(statement)
						@key.append_to(statement)
						statement.clause("IS NULL")
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
