# frozen_string_literal: true

# Copyright, 2012, by Samuel G. D. Williams. <http://www.codeotaku.com>
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

require_relative 'statement/count'

module DB
	module Model
		class View
			def initialize(session, model, cache = nil)
				@session = session
				@model = model
				@cache = cache
				
				@select = nil
			end
			
			attr :session
			attr :model
			attr :cache
			
			def create(**attributes)
				@model.create(@session, attributes)
			end
			
			def insert(keys, rows)
				@model.insert(@session, keys, rows)
			end
			
			def find(*key)
				@model.find(@session, *key)
			end
			
			def where(*arguments)
				@model.where(@session, *arguments)
			end
			
			def predicate
				nil
			end
			
			def count
				result = Statement::Select.new(@model,
					fields: Statement::Count::ALL,
					where: self.predicate,
				).call(@session).to_a
				
				# First row, first value:
				return result.first.first
			end
			
			def preload(name)
				@cache ||= {}
				
				scopes = []
				self.each do |record|
					scopes << record.send(name)
				end
				
				# Build a buffer of queries:
				query = @session.query
				first = true
				
				scopes.each do |scope|
					query.clause(";") unless first
					first = false
					
					scope.select.append_to(query)
				end
				
				query.send
				
				scopes.each do |scope|
					result = @session.next_result
					scope.update_cache(result)
				end
				
				return self
			end
			
			def each(&block)
				self.select.each(@session, @cache, &block)
			end
			
			def to_a
				records = []
				
				self.each do |record|
					records << record
				end
				
				return records
			end
			
			def select
				@select ||= Statement::Select.new(@model,
					where: self.predicate
				)
			end
			
			def to_s
				"\#<#{self.class} #{@model}>"
			end
			
			def inspect
				to_s
			end
		end
	end
end
