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
			class Select
				def initialize(source, fields: nil, where: nil, limit: nil)
					@source = source
					@fields = fields
					@where = where
					@limit = limit
				end
				
				def append_to(statement)
					statement.clause("SELECT")
					
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
					
					@limit&.append_to(statement)
					
					return statement
				end
				
				def to_sql(session)
					self.append_to(session.query)
				end
				
				def call(session)
					to_sql(session).call
				end
				
				def to_a(session, cache = nil)
					result = call(session)
					
					return apply(session, result, cache)
				end
				
				def apply(session, result, cache = nil)
					keys = result.field_names.map(&:to_sym)
					
					result.map do |row|
						@source.new(session, keys.zip(row).to_h, cache)
					end
				end
				
				def each(session, cache = nil)
					result = call(session)
					keys = result.field_names.map(&:to_sym)
					
					result.each do |row|
						yield @source.new(session, keys.zip(row).to_h, cache)
					end
				end
			end
		end
	end
end
