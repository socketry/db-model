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

require_relative 'statement/count'

module DB
	module Model
		class Table
			def initialize(session, model, **options)
				@session = session
				@model = model
				@options = options
			end
			
			attr :session
			attr :model
			attr :options
			
			def insert(keys, rows)
				@model.insert(@session, keys, rows)
			end
			
			def create(attributes)
				@model.create(@session, attributes)
			end
			
			def find(*key)
				@model.find(@session, *key)
			end
			
			def where(*arguments)
				@model.where(@session, *arguments)
			end
			
			def count
				result = Statement::Select.new(@model,
					fields: Statement::Count::ALL,
				).call(@session).to_a
				
				# First row, first value:
				return result.first.first
			end
			
			def to_s
				"\#<#{self.class} #{@model}>"
			end
			
			alias inspect to_s
		end
	end
end