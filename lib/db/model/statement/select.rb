# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2021, by Samuel Williams.

module DB
	module Model
		module Statement
			class Select
				def initialize(source, fields: nil, where: nil, limit: nil)
					@source = source
					@fields = fields
					@where = where
					@limit = limit
				end
				
				def append_to(statement, limit: @limit)
					statement = statement.clause("SELECT")
					
					if @fields
						@fields.append_to(statement)
					else
						statement.clause("*")
					end
					
					statement.clause("FROM")
					statement.identifier(@source.type)
					
					if @where
						statement.clause "WHERE"
						@where.append_to(statement)
					end
					
					limit&.append_to(statement)
					
					return statement
				end
				
				def to_sql(context)
					self.append_to(context)
				end
				
				def to_a(context, cache = nil)
					to_sql(context).call do |connection|
						result = connection.next_result
						
						return apply(context, result, cache)
					end
				end
				
				def apply(context, result, cache = nil)
					keys = result.field_names.map(&:to_sym)
					
					result.map do |row|
						@source.new(context, keys.zip(row).to_h, cache)
					end
				end
				
				def each(context, cache = nil)
					to_sql(context).call do |connection|
						result = connection.next_result
						keys = result.field_names.map(&:to_sym)
						
						result.each do |row|
							yield @source.new(context, keys.zip(row).to_h, cache)
						end
					end
				end
				
				def first(context, count, cache = nil)
					limit = @limit&.first(count) || Limit.new(count)
					
					append_to(context, limit: limit).call do |connection|
						result = connection.next_result
						
						return apply(context, result, cache)
					end
				end
			end
		end
	end
end
