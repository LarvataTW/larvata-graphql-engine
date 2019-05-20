module Mutations
  module AuthMutations
    SignInUser = GraphQL::Relay::Mutation.define do
      name "SignInUser"
      description "登入"

      input_field :email, !types.String
      input_field :password, !types.String

      return_field :token, types.String
      return_field :user, Types::UserType

      resolve ->(obj, args, ctx) {
        return unless args

        user = User.find_by email: args[:email]

        return unless user
        return unless user.valid_password?(args[:password])

        user.authentication_token = Devise.friendly_token
        user.save(validate: false)

        ctx[:session][:token] = user.authentication_token

        { user: user, token: user.authentication_token }
      }
    end

    SignOutUser = GraphQL::Relay::Mutation.define do
      name "SignOutUser"
      description "登出"

      return_field :user, Types::UserType

      resolve ->(obj, args, ctx) {
        authenticate_user!(ctx)

        current_user = ctx[:current_user]
        current_user.authentication_token = nil
        current_user.save(validate: false)

        ctx[:session][:token] = nil

        { user: current_user }
      }
    end
  end
end
