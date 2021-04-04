source "https://rubygems.org"

gemspec

group :maintenance, optional: true do
	gem "bake-modernize"
	gem "bake-bundler"
	
	gem "utopia-project"
end

group :adapters do
	gem "db-postgres", "~> 0.5.3"
	gem "db-mariadb", "~> 0.8.3"
end
