# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2021, by Samuel Williams.

require 'db/model'
require_relative 'client_context'

module DB
	module Model
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
		
		SchemaContext = Sus::Shared("schema context") do |adapter|
			include_context ClientContext, adapter
			
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
	end
end
