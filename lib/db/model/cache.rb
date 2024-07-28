# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2021, by Samuel Williams.

require_relative 'statement/select'
require_relative 'statement/count'

module DB
	module Model
		class Cache
			def initialize
				@relations = {}
				@records = {}
			end
			
			def empty?
				@relations.empty?
			end
			
			def size
				@relations.size
			end
			
			def fetch(key)
				@relations.fetch(key) do
					deduplicate(yield)
				end
			end
			
			def update(key, records)
				@relations[key] = records
			end
			
			def inspect
				"\#<#{self.class} #{@relations.size} relations; #{@records.size} records>"
			end
			
		protected
			
			def deduplicate(records)
				records.map do |record|
					@records[record] = record
				end
			end
		end
	end
end
