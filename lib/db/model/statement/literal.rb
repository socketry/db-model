# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2021-2024, by Samuel Williams.

module DB
	module Model
		module Statement
			class Literal
				def initialize(value)
					@value = value
				end
				
				attr :value
				
				def append_to(statement)
					statement.literal(@value)
				end
				
				def eql?(other)
					self.class.eql?(other.class) && self.value.eql?(other.value)
				end
				
				def hash
					[self.class, @value].hash
				end
			end
		end
	end
end
