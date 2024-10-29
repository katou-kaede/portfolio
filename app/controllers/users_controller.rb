class UsersController < ApplicationController
  before_action :authenticate_user!

  def index
    @users = current_user.friends.page(params[:page]).per(10)
  end

  def show
    @user = User.find(params[:id])
    @profile = @user.profile
    @events = @user.events.page(params[:page]).per(5)
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

  def toggle_friendship
    @user = User.find(params[:id])
    if current_user.friends_with?(@user)
      current_user.unfollow(@user)
    else
      current_user.follow(@user)
    end

    @button_container_id = "button_container_#{@user.id}"
    respond_to do |format|
      format.turbo_stream { render 'users/toggle_button' }
      format.html { redirect_to users_path }
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
