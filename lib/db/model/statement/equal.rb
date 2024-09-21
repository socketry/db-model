# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2021-2024, by Samuel Williams.

module DB
	module Model
		module Statement
			class Equal
				def initialize(source, fields, values)
					@source = source
					@fields = fields
					@values = values
				end
				
				def append_to(statement)
					first = true
					
					@fields.each_with_index do |field, index|
						statement.clause("AND") unless first
						first = false
						
						if field.is_a?(Symbol)
							statement.identifier(field)
						else
							field.append_to(statement)
						end
						
						statement.clause("=")
						statement.literal(@values[index])
					end
					
					return statement
				end
			end
		end
	end
end
