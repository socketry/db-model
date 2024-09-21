# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2021-2024, by Samuel Williams.

module DB
	module Model
		module Statement
			class Multiple
				def initialize(things)
					@things = things
				end
				
				def append_to(statement)
					first = true
					
					@things.each do |thing|
						statement.clause(",") unless first
						first = false
						
						thing.append_to(statement)
					end
					
					return statement
				end
			end
		end
	end
end
