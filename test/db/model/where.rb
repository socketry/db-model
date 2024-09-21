# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2021-2024, by Samuel Williams.

require "db/model/schema_context"

describe DB::Model::Where do
	DB::Adapters.each do |name, klass|
		describe klass, unique: name do
			include_context DB::Model::SchemaContext, klass.new(**CREDENTIALS)
			
			it "can query records" do
				users = schema.users.insert([:name], [
					["Ada Lovelace"],
					["Grace Hopper"],
					["Jean Bartik"],
					["Margaret Hamilton"],
					["Katherine Johnson"],
					["Frances Spence"],
					["Betty Holberton"],
					["Adele Goldberg"],
				])
				
				users = schema.users.where(name: "Ada Lovelace").or(name: "Grace Hopper")
				expect(users.count).to be == 2
			end
		end
	end
end
