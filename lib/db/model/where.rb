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

require_relative 'statement/select'
require_relative 'statement/predicate'

module DB
	module Model
		class Where
			include Enumerable
			
			def initialize(session, model, *arguments, **options, &block)
				@session = session
				@model = model
				@predicate = Statement::Predicate.where(*arguments, **options, &block)
			end
			
			attr_accessor :predicate
			
			def or(*arguments, **options, &block)
				@predicate |= Statement::Predicate.where(*arguments, **options, &block)
				
				return self
			end
			
			def and(*arguments, **options, &block)
				@predicate &= Statement::Predicate.where(*arguments, **options, &block)
				
				return self
			end
			
			def find(*key)
				return Statement::Select.new(@model,
					where: @predicate & @model.find_predicate(*key),
					limit: Statement::Limit::ONE
				).to_a(session)
			end
			
			def where(*arguments, **options, &block)
				self.class.new(@session, model,
					@predicate + Statement::Predicate.where(*arguments, **options, &block)
				)
			end
			
			def each(&block)
				Statement::Select.new(@model,
					where: @predicate
				).each(@session, &block)
			end
			
			def to_s
				"\#<#{self.class} #{@model} #{@predicate}>"
			end
			
			alias inspect to_s
		end
	end
end
