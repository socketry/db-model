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

require_relative 'relation'

module DB
	module Model
		class Scope < Relation
			def initialize(context, model, attributes, cache = nil)
				super(context, model, cache)
				
				@attributes = attributes
			end
			
			attr :attributes
			
			def create(**attributes)
				@model.create(@context, @attributes.merge(attributes))
			end
			
			def insert(keys, rows, **attributes)
				@model.insert(@context, keys, rows, **@attributes.merge(attributes))
			end
			
			def find(*key)
				@model.find(@context, *key)
			end
			
			def where(*arguments)
				@model.where(@context, *arguments)
			end
			
			def predicate
				Statement::Equal.new(@model, @attributes.keys, @attributes.values)
			end
			
			def cache_key
				[@model, @attributes]
			end
			
			def to_s
				"\#<#{self.class} #{@model} #{@attributes}>"
			end
		end
	end
end
