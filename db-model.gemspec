
require_relative "lib/db/model/version"

Gem::Specification.new do |spec|
	spec.name = "db-model"
	spec.version = DB::Model::VERSION
	
	spec.summary = "A object-relational mapper."
	spec.authors = ["Samuel Williams"]
	spec.license = "MIT"
	
	spec.homepage = "https://github.com/socketry/db-model"
	
	spec.files = Dir.glob('{lib}/**/*', File::FNM_DOTMATCH, base: __dir__)
	
	spec.required_ruby_version = ">= 2.5"
	
	spec.add_dependency "db"
	
	spec.add_development_dependency "async-rspec", "~> 1.10"
	spec.add_development_dependency "bundler"
	spec.add_development_dependency "covered"
	spec.add_development_dependency "rspec", "~> 3.0"
end
