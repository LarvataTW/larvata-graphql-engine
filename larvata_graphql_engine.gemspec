$:.push File.expand_path("lib", __dir__)

# Maintain your gem's version:
require "larvata_graphql_engine/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |spec|
  spec.name        = "larvata_graphql_engine"
  spec.version     = LarvataGraphqlEngine::VERSION
  spec.authors     = ["snowild"]
  spec.email       = ["snowild@gmail.com"]
  spec.homepage    = "http://larvata.tw"
  spec.summary     = "Larvata GraphQL utils engine"
  spec.description = "Provide GraphQL utils for Larvata."
  spec.license     = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata["allowed_push_host"] = ""
  else
    raise "RubyGems 2.0 or newer is required to protect against " \
      "public gem pushes."
  end

  spec.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]

  spec.add_dependency "rails", "~> 5.2.3"

  spec.add_dependency 'ransack', "~> 2.1.1"

  spec.add_dependency 'kaminari', '~> 1.1.1'
  spec.add_dependency 'kaminari-i18n', '~> 0.5.0'

  spec.add_dependency 'graphql', "~> 1.9.4"
  spec.add_dependency 'batch-loader', "~> 1.4.0"
  spec.add_dependency 'graphql-query-resolver', "~> 0.2.0"
  spec.add_dependency 'search_object', '1.2.0'
  spec.add_dependency 'search_object_graphql', '0.1'
  spec.add_dependency 'graphiql-rails', '1.4.4'
  spec.add_dependency 'apollo_upload_server', '2.0.0.beta.3'
  spec.add_dependency 'apollo-tracing', "~> 1.6.0"

  spec.add_development_dependency "mysql2"
end
