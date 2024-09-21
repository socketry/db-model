# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2021-2024, by Samuel Williams.

require_relative "statement/select"
require_relative "statement/predicate"

require_relative "countable"

module DB
	module Model
		class Where
			def initialize(context, model, *arguments, **options, &block)
				@context = context
				@model = model
				@predicate = Statement::Predicate.where(*arguments, **options, &block)
				
				@select = nil
			end
			
			attr_accessor :predicate
			
			include Countable, Deletable
			
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
				).to_a(context)
			end
			
			def where(*arguments, **options, &block)
				self.class.new(@context, model,
					@predicate + Statement::Predicate.where(*arguments, **options, &block)
				)
			end
			
			def select
				@select ||= Statement::Select.new(@model,
					where: @predicate
				)
			end
			
			def each(&block)
				self.select.each(@context, &block)
			end
			
			def first(count = nil)
				if count
					self.select.first(@context, count)
				else
					self.select.first(@context, 1).first
				end
			end
			
			def to_s
				"\#<#{self.class} #{@model} #{@predicate}>"
			end
			
			alias inspect to_s
		end
	end
end
