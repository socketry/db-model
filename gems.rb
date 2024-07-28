# Released under the MIT License.
# Copyright, 2021, by Samuel Williams.

source "https://rubygems.org"

gemspec

group :maintenance, optional: true do
	gem "bake-modernize"
	gem "bake-gem"
	
	gem "utopia-project"
end

group :adapters do
	gem "db-postgres", "~> 0.5.3"
	gem "db-mariadb", "~> 0.8.3"
end

group :test do
	gem "sus"
	gem "covered"
	gem "decode"
	gem "rubocop"
	
	gem "sus-fixtures-async"
	
	gem "bake-test"
	gem "bake-test-external"
end