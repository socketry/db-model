# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2021, by Samuel Williams.

module DB
	module Model
		module Statement
			class Delete
				def initialize(source, where: nil, order: nil, limit: nil)
					@source = source
					@where = where
					@order = order
					@limit = limit
				end
				
				def to_sql(context)
					statement = context.clause("DELETE FROM")
					
					statement.identifier(@source.type)
					
					if @where
						statement.clause "WHERE"
						@where.append_to(statement)
					end
					
					@order&.append_to(statement)
					@limit&.append_to(statement)
					
					return statement
				end
				
				def call(context)
					to_sql(context).call
				end
			end
		end
	end
end
