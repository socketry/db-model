# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2021-2024, by Samuel Williams.

module DB
	module Model
		module Statement
			class Truncate
				def initialize(source)
					@source = source
				end
				
				def to_sql(context)
					statement = context.clause("TRUNCATE TABLE")
					
					statement.identifier(@source.type)
					
					return statement
				end
				
				def call(context)
					to_sql(context).call
				end
			end
		end
	end
end
