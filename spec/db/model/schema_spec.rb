# frozen_string_literal: true

# Copyright, 2021, by Samuel G. D. Williams. <http://www.codeotaku.com>
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.

require_relative 'schema_context'

RSpec.shared_examples DB::Model::Schema do |adapter|
	include_context TestSchema, adapter
	
	it "can truncate tables" do
		schema.users.truncate
		expect(schema.users).to be_empty
		
		schema.posts.truncate
		expect(schema.posts).to be_empty
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
		
		expect(schema.users.to_a).to be_kind_of Array
		
		user = schema.users.first
		
		expect(user.posts.to_a).to be_kind_of Array
	end
	
	it "can preload posts" do
		names = 100.times.map{|i| ["Robot #{i}"]}
		users = schema.users.insert([:name], names)
		
		posts = 10.times.map{|i| ["Post #{i}"]}
		users.each do |user|
			user.posts.insert([:body], posts)
		end
		
		users = schema.users.preload(:posts)
		
		expect(users.cache).to_not be_empty
		expect(users.cache.size).to be == 100
	end
end

DB::Adapters.each do |name, klass|
	RSpec.describe klass do
		it_behaves_like DB::Model::Schema, klass.new(**CREDENTIALS)
	end
end
