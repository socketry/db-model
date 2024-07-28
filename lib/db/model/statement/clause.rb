# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2021, by Samuel Williams.

module DB
	module Model
		module Statement
			class Clause
				def initialize(value)
					@value = value
				end
				
				def append_to(statement)
					statement.clause(@value)
				end
				
				ANY = self.new('*')
			end
		end
	end
end
