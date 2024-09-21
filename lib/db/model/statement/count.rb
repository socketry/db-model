# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2021-2024, by Samuel Williams.

require_relative "clause"

module DB
	module Model
		module Statement
			class Count
				def initialize(expression)
					@expression = expression
				end
				
				def append_to(statement)
					statement.clause("COUNT(")
					
					@expression.append_to(statement)
					
					statement.clause(")")
				end
				
				ALL = self.new(Clause::ANY)
			end
		end
	end
end
