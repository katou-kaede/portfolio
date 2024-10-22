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
    if @user.update(user_params)
      redirect_to user_path(current_user), notice: 'プロフィールが更新されました'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def user_params
    params.require(:user).permit(:email, :password, :friend_code, profile_attributes: [:id, :name, :bio, :birthday, :avatar])
  end

  def profile_params
    params.require(:profile).permit(:name, :bio, :birthday, :avatar)
  end
end
