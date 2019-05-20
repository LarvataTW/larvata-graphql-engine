module Helpers::QueryHelper
  # 驗證是否登入
  def authenticate_user!(ctx)
    raise GraphQL::ExecutionError.new("請傳入正確的 Token 到 Header 的  X-Token 內。") unless ctx[:current_user]
  end
end
