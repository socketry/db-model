# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2021, by Samuel Williams.

require 'db/model/schema_context'

describe DB::Model::Schema do
	DB::Adapters.each do |name, klass|
		describe klass, unique: name do
			include_context DB::Model::SchemaContext, klass.new(**CREDENTIALS)
	
			it "can truncate tables" do
				schema.users.truncate
				expect(schema.users).to be(:empty?)
				
				schema.posts.truncate
				expect(schema.posts).to be(:empty?)
			end
			
			it "can insert and find records by id" do
				users = schema.users.insert([:name], [
					["Ada Lovelace"],
					["Grace Hopper"],
				])
				
				schema.posts.insert([:user_id, :body], [
					[users[0].id, "COBOL"],
					[users[1].id, "Note G"],
					[users[1].id, "Bernoulli Numbers"]
				])
				
				user = schema.users.find(users.first.id)
				expect(user.name).to be == users.first.name
				
				expect(schema.users.count).to be == 2
				expect(schema.posts.count).to be == 3
			end
			
			it "can insert and get them all" do
				users = schema.users.insert([:name], [
					["Ada Lovelace"],
					["Grace Hopper"],
				])
				
				schema.posts.insert([:user_id, :body], [
					[users[0].id, "COBOL"],
					[users[1].id, "Note G"],
					[users[1].id, "Bernoulli Numbers"]
				])
				
				expect(schema.users.to_a).to be_a Array
				
				user = schema.users.first
				
				expect(user.posts.to_a).to be_a Array
			end
			
			it "can preload posts" do
				names = 100.times.map{|i| ["Robot #{i}"]}
				users = schema.users.insert([:name], names)
				
				posts = 10.times.map{|i| ["Post #{i}"]}
				users.each do |user|
					user.posts.insert([:body], posts)
				end
				
				users = schema.users.preload(:posts)
				
				expect(users.cache).not.to be(:empty?)
				expect(users.cache.size).to be == 100
			end
		
		end
	end
end
