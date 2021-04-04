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

require_relative 'view'

module DB
	module Model
		class Scope < View
			include Enumerable
			
			def initialize(session, model, attributes, cache = nil)
				super(session, model, cache)
				
				@attributes = attributes
				@select = nil
			end
			
			attr :attributes
			
			def create(**attributes)
				@model.create(@session, @attributes.merge(attributes))
			end
			
			def predicate
				Statement::Equal.new(@model, @attributes.keys, @attributes.values)
			end
			
			def cache_key
				[@model, @attributes]
			end
			
			def update_cache(result)
				key = [@model, @attributes]
				@cache[key] = self.select.apply(@session, result)
			end
			
			def each(&block)
				if @cache
					@cache.fetch([@model, @attributes]) do
						self.select.to_a(@session, @cache)
					end.each(&block)
				else
					self.select.each(@session, &block)
				end
			end
			
			def select
				@select ||= Statement::Select.new(@model,
					where: self.predicate
				)
			end
			
			def to_s
				"\#<#{self.class} #{@model} #{@attributes}>"
			end
		end
	end
end
