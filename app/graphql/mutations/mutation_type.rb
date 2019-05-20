Mutations::MutationType = GraphQL::ObjectType.define do
  name "Mutation"

  field :signInUser, field: Mutations::AuthMutations::SignInUser.field
  field :signOutUser, field: Mutations::AuthMutations::SignOutUser.field

  field :createCustomModification, field: Mutations::CustomModificationMutations::Create.field
end
