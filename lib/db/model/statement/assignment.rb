# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2021-2024, by Samuel Williams.

module DB
	module Model
		module Statement
			class Assignment
				def initialize(attributes)
					@attributes = attributes
				end
				
				def append_to(statement)
					first = true
					
					statement.clause "SET"
					
					@attributes.each do |key, value|
						statement.clause(",") unless first
						first = false
						
						statement.identifier(key)
						statement.clause("=")
						statement.literal(value)
					end
					
					return statement
				end
			end
		end
	end
end
