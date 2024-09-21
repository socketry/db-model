# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2021-2024, by Samuel Williams.

module DB
	module Model
		module Statement
			class Limit
				def initialize(count, offset: nil)
					@count = count
					@offset = offset
				end
				
				def append_to(statement)
					statement.clause("LIMIT")
					statement.literal(@count)
					
					if @offset
						statement.clause("OFFSET")
						statement.literal(@offset)
					end
					
					return statement
				end
				
				def first(count)
					self.new(count, offset: @offset)
				end
				
				ONE = self.new(1)
			end
		end
	end
end
