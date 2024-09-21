# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2021-2024, by Samuel Williams.

require_relative "countable"
require_relative "deletable"

module DB
	module Model
		class Relation
			def initialize(context, model, cache = nil)
				@context = context
				@model = model
				@cache = cache
				
				@select = nil
			end
			
			attr :context
			attr :model
			attr :cache
			
			include Countable, Deletable
			
			def create(**attributes)
				self.new(**attributes).save
			end
			
			def new(**attributes)
				@model.new(@context, {}, @cache).assign(attributes)
			end
			
			def insert(keys, rows, **attributes)
				@model.insert(@context, keys, rows, **attributes)
			end
			
			def find(*key)
				if predicate = self.predicate
					predicate = predicate & @model.find_predicate(*key)
				else
					predicate = @model.find_predicate(*key)
				end
				
				return Statement::Select.new(@model,
					where: predicate,
					limit: Statement::Limit::ONE
				).to_a(@context).first
			end
			
			def where(*arguments, **options, &block)
				where = @model.where(@context, *arguments, **options, &block)
				
				if predicate = self.predicate
					where.predicate &= predicate
				end
				
				return where
			end
			
			def predicate
				nil
			end
			
			def preload(name)
				@cache ||= Cache.new
				
				scopes = []
				self.each do |record|
					scopes << record.send(name)
				end
				
				# Build a buffer of queries:
				query = @context.query
				first = true
				
				scopes.each do |scope|
					query.clause(";") unless first
					first = false
					
					scope.select.append_to(query)
				end
				
				query.call do |connection|
					scopes.each do |scope|
						result = connection.next_result
						scope.update_cache(result)
					end
				end
				
				return self
			end
			
			def each(cache: @cache, &block)
				if @cache
					@cache.fetch(self.cache_key) do
						self.select.to_a(@context, @cache)
					end.each(&block)
				else
					self.select.each(@context, &block)
				end
			end
			
			def first(count = nil)
				if count
					self.select.first(@context, count, @cache)
				else
					self.select.first(@context, 1, @cache).first
				end
			end
			
			def to_a
				records = []
				
				self.each do |record|
					records << record
				end
				
				return records
			end
			
			def cache_key
				[@model, self.predicate]
			end
			
			def update_cache(result)
				@cache.update(self.cache_key, self.select.apply(@context, result))
			end
			
			def select
				@select ||= Statement::Select.new(@model, where: self.predicate)
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
