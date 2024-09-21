# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2021-2024, by Samuel Williams.

require_relative "relation"
require_relative "statement/truncate"

module DB
	module Model
		class Table < Relation
			def cache_key
				[@model]
			end
			
			def truncate
				Statement::Truncate.new(@model).call(@context)
			end
		end
	end
end
