# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2021-2024, by Samuel Williams.

module DB
	module Model
		module Statement
			class Tuple
				def initialize(values)
					@values = values
				end
				
				attr :values
				
				def append_to(statement)
					first = true
					
					statement.clause("(")
					@values.each do |value|
						statement.clause(",") unless first
						first = false
						
						statement.literal(value)
					end
					statement.clause(")")
					
					return statement
				end
				
				def eql?(other)
					self.class.eql?(other.class) && self.values.eql?(other.values)
				end
				
				def hash
					[self.class, @values].hash
				end
			end
		end
	end
end
