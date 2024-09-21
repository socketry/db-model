# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2021-2024, by Samuel Williams.

module DB
	module Model
		module Statement
			class Replace
				def initialize(source, fields, values)
					@source = source
					@fields = fields
					@values = values
				end
				
				def to_sql(context)
					statement = context.query("REPLACE INTO")
					
					statement.identifier(@source.type)
					
					statement.clause("(")
					@fields.append_to(statement)
					statement.clause(") VALUES")
					
					@values.append_to(statement)
					
					statement.clause("RETURNING *")
					
					return statement
				end
				
				def to_a(context, klass)
					to_sql(context).call do |connection|
						result = connection.next_result
						keys = result.field_names.map(&:to_sym)
						
						result.map do |row|
							klass.new(context, keys.zip(row).to_h)
						end
					end
				end
			end
		end
	end
end
