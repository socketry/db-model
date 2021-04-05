# Getting Started

This guide explains how to use `db-model` for database schemas.

## Installation

Add the gem to your project:

~~~ bash
$ bundle add db-model
~~~

## Core Concepts

`db-model` has several core concepts:

- {ruby DB::Model::Schema} defines the schema of your database and must be attached to a {ruby DB::Session} in order to interact with a real database. There is no hidden per-thread state.
- {ruby DB::Model::Record} defines how to interact with rows of data from a table or scope.
- {ruby DB::Model::Relation} defines a way of reading records and there are specific sub-classes:
	- {ruby DB::Model::Table} defines a relation which includes all the rows in a table.
	- {ruby DB::Model::Scope} defines a relationship with a specific record (i.e. has one, has many, etc).
- {ruby DB::Model::Where} is used for executing select statements on a database and reading results.

## Connecting to Postgres

Add the Postgres adaptor to your project:

~~~ bash
$ bundle add db-postgres
~~~

Set up the client with the appropriate credentials:

~~~ ruby
require 'async'
require 'db/client'
require 'db/postgres'

# Create the client and connection pool:
client = DB::Client.new(DB::Postgres::Adapter.new(database: 'test'))

# This is our database schema:
class TestSchema
	include DB::Model::Schema
	
	class User
		include DB::Model::Record
		
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

# Create an event loop:
Sync do
	# Connect to the database:
	client.transaction do |context|
		schema = TestSchema.new(context)
		
		# Create a user:
		user = schema.users.create(name: "Posty McPostface")
		
		# Insert several posts:
		user.posts.insert([:body], [
			["Hello World"],
			["Goodbye World"]
		])
	end
end
~~~
