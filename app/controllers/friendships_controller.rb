class FriendshipsController < ApplicationController
  before_action :authenticate_user!, only:[:index, :show]

  def index
    @friends = current_user.friends.page(params[:page]).per(10)
  end

  def show
  end

  def toggle_friendship
    @friend = User.find(params[:id])
    if current_user.friends_with?(@friend)
      current_user.unfollow(@friend)
    else
      current_user.follow(@friend)
    end

    @button_container_id = "button_container_#{@friend.id}"
    respond_to do |format|
      format.turbo_stream { render 'friendships/toggle_button' }
      format.html { redirect_to friendships_path }
    end
  end
end
