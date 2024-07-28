# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2021, by Samuel Williams.

require_relative 'relation'

module DB
	module Model
		class Scope < Relation
			def initialize(context, model, attributes, cache = nil)
				super(context, model, cache)
				
				@attributes = attributes
			end
			
			attr :attributes
			
			def new(**attributes)
				@model.new(@context, {}, @cache).assign(**@attributes.merge(attributes))
			end
			
			def insert(keys, rows, **attributes)
				@model.insert(@context, keys, rows, **@attributes.merge(attributes))
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
