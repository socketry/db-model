# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2021, by Samuel Williams.

module DB
	module Model
		module Statement
			class Join
				def initialize(target, where, mode = "INNER JOIN")
					@target = target
					@predicates = predicates
					@mode = mode
				end
				
				def append_to(statement)
					statement.clause(@mode)
					
					statement.identifier(@target.type)
					
					statement.clause("ON")
					
					@where.append_to(statement)
					
					return statement
				end
			end
		end
	end
end
