# frozen_string_literal: true

require_relative "lib/db/model/version"

Gem::Specification.new do |spec|
	spec.name = "db-model"
	spec.version = DB::Model::VERSION
	
	spec.summary = "A object-relational mapper."
	spec.authors = ["Samuel Williams"]
	spec.license = "MIT"
	
	spec.cert_chain  = ['release.cert']
	spec.signing_key = File.expand_path('~/.gem/release.pem')
	
	spec.homepage = "https://github.com/socketry/db-model"
	
	spec.metadata = {
		"documentation_uri" => "https://socketry.github.io/db-model/",
		"source_code_uri" => "https://github.com/socketry/db-model.git",
	}
	
	spec.files = Dir.glob(['{lib}/**/*', '*.md'], File::FNM_DOTMATCH, base: __dir__)
	
	spec.required_ruby_version = ">= 3.1"
	
	spec.add_dependency "db", "~> 0.11"
end
