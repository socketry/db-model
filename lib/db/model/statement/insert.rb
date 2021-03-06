# frozen_string_literal: true

# Copyright, 2021, by Samuel G. D. Williams. <http://www.codeotaku.com>
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.

module DB
	module Model
		module Statement
			class Insert
				def initialize(source, fields, values)
					@source = source
					@fields = fields
					@values = values
				end
				
				def to_sql(context)
					statement = context.query("INSERT INTO")
					
					statement.identifier(@source.type)
					
					statement.clause("(")
					@fields.append_to(statement)
					statement.clause(") VALUES")
					
					@values.append_to(statement)
					
					statement.clause("RETURNING *")
					
					return statement
				end
				
				def call(context)
					to_sql(context).call do |connection|
						result = connection.next_result
						keys = result.field_names.map(&:to_sym)
						
						result.each do |row|
							yield(keys.zip(row).to_h)
						end
					end
				end
				
				def to_a(context)
					to_sql(context).call do |connection|
						result = connection.next_result
						keys = result.field_names.map(&:to_sym)
						
						result.map do |row|
							@source.new(context, keys.zip(row).to_h)
						end
					end
				end
			end
		end
	end
end
