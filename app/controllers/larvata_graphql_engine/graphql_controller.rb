module LarvataGraphqlEngine
  class GraphqlController < ApplicationController
    skip_before_action :verify_authenticity_token

    def execute
      variables = ensure_hash(params[:variables])
      query = params[:query]
      operation_name = params[:operationName]

      context = {
        # we need to provide session and current user
        session: session,
        current_user: current_user
      }

      result = Schema.execute(query, variables: variables, context: context, operation_name: operation_name)

      render json: result
    rescue => e
      raise e unless Rails.env.development?
      handle_error_in_development e
    end

    private

    # 如果 session 中有 token，或是 request header 中有 X-Token，如果可以取得對應使用者，則建立 current_user
    def current_user
      token = session[:token] || request.headers["X-Token"]
      # if we want to change the sign-in strategy, this is the place to do it
      return unless token

      find_user_by_token(token)
    rescue ActiveSupport::MessageVerifier::InvalidSignature
      nil
    end

    def find_user_by_token(token)
      User.includes(:profile).find_by_tokens(token)
    end

    # Handle form data, JSON body, or a blank value
    def ensure_hash(ambiguous_param)
      case ambiguous_param
      when String
        if ambiguous_param.present?
          ensure_hash(JSON.parse(ambiguous_param))
        else
          {}
        end

      when Hash, ActionController::Parameters
        ambiguous_param
      when nil
        {}
      else
        raise ArgumentError, "Unexpected parameter: #{ambiguous_param}"
      end
    end

    def handle_error_in_development(e)
      logger.error e.message
      logger.error e.backtrace.join("\n")

      render json: { error: { message: e.message, backtrace: e.backtrace }, data: {} }, status: 500
    end
  end
end
