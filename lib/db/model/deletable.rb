# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2021, by Samuel Williams.

require_relative 'statement/delete'

module DB
	module Model
		module Deletable
			def delete
				Statement::Delete.new(@model,
					where: self.predicate,
				).call(@context)
			end
		end
	end
end
