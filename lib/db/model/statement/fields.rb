# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2021, by Samuel Williams.

module DB
	module Model
		module Statement
			class Fields
				def initialize(fields)
					@fields = fields
				end
				
				def append_to(statement)
					first = true
					
					@fields.each do |field|
						statement.clause(",") unless first
						first = false
						
						statement.identifier(field)
					end
				end
			end
		end
	end
end
