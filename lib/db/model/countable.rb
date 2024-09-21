# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2021-2024, by Samuel Williams.

require_relative "statement/select"
require_relative "statement/count"

module DB
	module Model
		module Countable
			def count(fields = Statement::Count::ALL)
				Statement::Select.new(@model,
					fields: fields,
					where: self.predicate,
				).to_sql(@context).call do |connection|
					result = connection.next_result
					
					row = result.to_a.first
					
					# Return the count:
					return row.first
				end
			end
			
			def empty?
				self.count == 0
			end
		end
	end
end
