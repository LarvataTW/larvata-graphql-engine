Rails.application.routes.draw do
  mount LarvataGraphqlEngine::Engine => "/larvata_graphql_engine"
end
