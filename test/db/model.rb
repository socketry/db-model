# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2021-2024, by Samuel Williams.

require "db/model"

describe DB::Model do
	it "has a version number" do
		expect(DB::Model::VERSION).to be =~ /\d+\.\d+\.\d+/
	end
end
