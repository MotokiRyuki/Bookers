class SessionsController < ApplicationController
    skip_before_action :verify_authenticity_token, only: :create

    def create
        # ユーザの取得
        user = User.find_by(email: params[:email])&.authenticate(params[:password])
    
        # ペイロードの作成
        payload = {
          iss: "example_app", # JWTの発行者
          sub: user.id, # JWTの主体
          exp: (DateTime.current + 14.days).to_i # JWTの有効期限
        }
    
        # 秘密鍵の取得
        rsa_private = OpenSSL::PKey::RSA.new(File.read(Rails.root.join('config/auth/service.key')))
    
        # JWTの作成
        token = JWT.encode(payload, rsa_private, "RS256")
    
        # JWTをCookieにセット
        cookies[:token] = token
    
        render json: { name: user.name, email: user.email, password: user.password }, status: :created


      end
end
