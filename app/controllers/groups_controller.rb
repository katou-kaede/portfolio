class GroupsController < ApplicationController
  before_action :authenticate_user!
  before_action :correct_user, only: [:edit, :update, :destroy]

  def new
    @group = Group.new
    @group.group_members.build
    @friends = current_user.friends.includes(:profile)
  end

  def create
    @group = current_user.groups.build(group_params)
    @group.user_id = current_user.id
    if @group.save
      @group.member_ids = params[:group][:member_ids]
      redirect_to groups_path, notice: 'グループが作成されました'
    else
      @friends = current_user.friends.includes(:profile)
      render :new, status: :unprocessable_entity, alert: 'グループ作成に失敗しました'
    end
  end

  def index
    @groups = Group.where(user_id: current_user.id).includes(:group_members).page(params[:page]).per(10)
  end

  def show
  end

  def edit
  end

  def update
  end

  def destroy
  end

  private

  def group_params
    params.require(:group).permit(:name, member_ids: [])
  end

  def correct_user
    unless @group.user_id == current_user.id
      redirect_to events_path, alert: 'このグループを編集・削除する権限がありません'
    end
  end
end
