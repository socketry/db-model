# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2021-2024, by Samuel Williams.

module DB
	module Model
		module Statement
			class Update
				def initialize(source, assignment, where)
					@source = source
					@assignment = assignment
					@where = where
				end
				
				def to_sql(context)
					statement = context.query("UPDATE")
					
					statement.identifier(@source.type)
					
					@assignment.append_to(statement)
					
					if @where
						statement.clause "WHERE"
						@where.append_to(statement)
					end
					
					return statement
				end
				
				def call(context)
					to_sql(context).call
				end
			end
		end
	end
end
