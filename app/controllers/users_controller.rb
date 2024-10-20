class UsersController < ApplicationController
  before_action :authenticate_user!

  def show
    @user = current_user
    @profile = @user.profile
  end

  def edit
    @user = current_user
    @profile = @user.profile
  end

  def update
    @user = current_user
    if @user.update(user_params) && @user.profile.update(profile_params)
      redirect_to my_page_path, notice: 'プロフィールが更新されました。'
    else
      render :edit
    end
  end

  private

  def user_params
    params.require(:user).permit(:email, :password, :friend_code)
  end

  def profile_params
    params.require(:profile).permit(:name, :bio, :birthday, :avatar)
  end
end
