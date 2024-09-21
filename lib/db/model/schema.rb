# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2021-2024, by Samuel Williams.

require_relative "table"
require_relative "cache"

module DB
	module Model
		module Schema
			def initialize(context, cache: Cache.new)
				@context = context
				@cache = cache
			end
			
			attr :context
			attr :cache
			
			def table(model)
				Table.new(@context, model, @cache)
			end
			
			def inspect
				"\#<#{self.class} #{@context.class} cache=#{@cache}>"
			end
		end
	end
end
