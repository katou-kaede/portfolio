# frozen_string_literal: true

class Users::RegistrationsController < Devise::RegistrationsController
  # before_action :configure_sign_up_params, only: [:create]
  # before_action :configure_account_update_params, only: [:update]

  # GET /resource/sign_up
  def new
    self.resource = User.new
    resource.build_profile
    respond_with resource
  end

  # POST /resource
  def create
    super do |resource|
      if resource.persisted? # ユーザーが正常に保存されたかチェック
        flash[:notice] = "ユーザー登録が完了しました"
      else
        flash.now[:alert] = "ユーザー登録に失敗しました"
        # render :new, status: :unprocessable_entity
      end
    end
  end

  # GET /resource/edit
  # def edit
  #   super
  # end

  # PUT /resource
  # def update
  # super
  # end

  # DELETE /resource
  # def destroy
  # super
  # end

  # GET /resource/cancel
  # Forces the session data which is usually expired after sign
  # in to be expired now. This is useful if the user wants to
  # cancel oauth signing in/up in the middle of the process,
  # removing all OAuth session data.
  # def cancel
  #   super
  # end

  protected

  # パスワードなしで他の情報を更新する
  def update_resource(resource, params)
    if params[:password].present? && params[:password_confirmation].present?
      resource.update_with_password(params)
    else
      resource.update_without_password(params.except(:current_password))
    end
  end

  def after_update_path_for(resource)
    user_path(resource)
  end

  # If you have extra params to permit, append them to the sanitizer.
  # def configure_sign_up_params
  #   devise_parameter_sanitizer.permit(:sign_up, keys: [:attribute])
  # end

  # If you have extra params to permit, append them to the sanitizer.
  # def configure_account_update_params
  #   devise_parameter_sanitizer.permit(:account_update, keys: [:attribute])
  # end

  # The path used after sign up.
  # def after_sign_up_path_for(resource)
  #   super(resource)
  # end

  # The path used after sign up for inactive accounts.
  # def after_inactive_sign_up_path_for(resource)
  #   super(resource)
  # end

  private

  def user_params
    params.require(:user).permit(:email, :password, :password_confirmation, :current_password, :friend_code, profile_attributes: [ :name, :bio, :birthday, :avatar ])
  end

  def profile_params
    params.require(:profile).permit(:name, :bio, :birthday, :avatar)
  end
end
