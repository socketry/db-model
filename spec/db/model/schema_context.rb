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

require 'async'
require 'db/client'
require 'db/model'

class TestSchema
	include DB::Model::Schema
	
	class User
		include DB::Model::Record
		
		# @type = :users
		
		property :id
		property :name
		
		def posts
			scope(Post, user_id: self.id)
		end
	end
	
	class Post
		include DB::Model::Record
		
		property :id
		property :user_id
		
		def user
			scope(User, id: self.user_id)
		end
	end
	
	def users
		table(User)
	end
	
	def posts
		table(Post)
	end
end

RSpec.shared_context TestSchema do |adapter|
	include_context Async::RSpec::Reactor
	
	let(:client) {DB::Client.new(adapter)}
	let(:context) {client.context}
	let(:schema) {TestSchema.new(context)}
	
	before do
		client.transaction do |context|
			context.query("DROP TABLE IF EXISTS %{table}", table: TestSchema::User.type).call
			context.query("DROP TABLE IF EXISTS %{table}", table: TestSchema::Post.type).call
			
			context.clause("CREATE TABLE IF NOT EXISTS")
				.identifier(TestSchema::User.type)
				.clause("(")
					.key_column.clause(",")
					.identifier(:name).clause("TEXT NOT NULL")
				.clause(")").call
			
			context.clause("CREATE TABLE IF NOT EXISTS")
				.identifier(TestSchema::Post.type)
				.clause("(")
					.key_column.clause(",")
					.key_column(:user_id, primary: false, null: false).clause(",")
					.identifier(:body).clause("TEXT NOT NULL")
				.clause(")").call
		end
	end
end
