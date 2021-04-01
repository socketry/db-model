source "https://rubygems.org"

gemspec

group :maintenance, optional: true do
	gem "bake-modernize"
	gem "bake-bundler"
	
	gem "utopia-project"
end

group :adapters do
	gem "db-postgres"
	gem "db-mariadb"
end
