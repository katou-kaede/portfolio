class OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def line
    basic_action
  end

  private

  def basic_action
    @omniauth = request.env["omniauth.auth"]

    if @omniauth.present?
      # 既存ユーザーを探すか、新規作成
      user = User.find_or_initialize_by(provider: @omniauth["provider"], uid: @omniauth["uid"])
      if user.new_record?
        # メールアドレスの取得またはフェイクのメールアドレス作成
        email = @omniauth["info"]["email"] || fake_email(@omniauth["uid"], @omniauth["provider"])
        # Userの属性を設定
        user.assign_attributes(
          provider: @omniauth["provider"],
          uid: @omniauth["uid"],
          email: email,
          password: Devise.friendly_token[0, 20]
        )
        # ProfileにNameを設定
        user.build_profile(name: @omniauth["info"]["name"])
        user.save!
      end

      # ユーザーの情報更新
      user.set_values(@omniauth) if user.respond_to?(:set_values)

      # ユーザーをサインイン
      sign_in(:user, user)
      flash[:notice] = "ログインしました"
    else
      flash[:alert] = "ログインに失敗しました"
    end
    redirect_to root_path
  end

  def fake_email(uid, provider)
    "#{uid}-#{provider}@example.com"
  end
end
