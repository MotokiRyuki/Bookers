class UsersController < ApplicationController
    def show
        # CookieからJWTを取得
        token = cookies[:token]
    
        # 秘密鍵の取得
        rsa_private = OpenSSL::PKey::RSA.new(File.read(Rails.root.join('config/auth/service.key')))
    
        # JWTのデコード。JWTからペイロードが取得できない場合は認証エラーにする
        begin
          decoded_token = JWT.decode(token, rsa_private, true, { algorithm: 'RS256' })
        rescue JWT::DecodeError, JWT::ExpiredSignature, JWT::VerificationError
          return render json: { message: 'unauthorized' }, status: :unauthorized
        end
    
        # subクレームからユーザーIDを取得
        user_id = decoded_token.first["sub"]
    
        # ユーザーを検索
        user = User.find(user_id)
    
        # userが取得できた場合はユーザー情報を返す、取得できない場合は認証エラー
        if user.nil?
          render json: { message: 'unauthorized' }, status: :unauthorized
        else
          render json: {
            user: {
              token: token,
              id: user.id,
              name: user.name,
              emai: user.email
            }
          }, status: :ok
        end
    end
end
