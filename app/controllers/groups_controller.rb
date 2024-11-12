class GroupsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_group, only: [ :show, :edit, :update, :destroy ]
  before_action :correct_user, only: [ :edit, :update, :destroy ]

  def new
    @group = Group.new
    @group.group_members.build
    @friends = current_user.friends.includes(:profile)
  end

  def create
    @group = current_user.groups.build(group_params)
    @group.user_id = current_user.id
    if @group.save
      @group.member_ids = params[:group][:member_ids] || []
      redirect_to @group, notice: "グループが作成されました"
    else
      @friends = current_user.friends.includes(:profile)
      render :new, status: :unprocessable_entity, alert: "グループ作成に失敗しました"
    end
  end

  def index
    if params[:search].present?
      @groups = Group.where(user_id: current_user.id).where("name ILIKE ?", "%#{params[:search]}%").includes(:group_members).page(params[:page]).per(10)
      @searching = true
    else
      @groups = Group.where(user_id: current_user.id).includes(:group_members).page(params[:page]).per(10)
      @searching = false
    end
  end

  def show
  end

  def edit
    @friends = current_user.friends.includes(:profile)
  end

  def update
    if @group.update(group_params)
      @group.member_ids = params[:group][:member_ids] || []
      redirect_to @group, notice: "グループが更新されました"
    else
      flash.now[:alert] = "グループの更新に失敗しました"
      render :edit
    end
  end

  def destroy
    @group.destroy
    redirect_to groups_path, notice: "グループが削除されました"
  end

  private

  def group_params
    params.require(:group).permit(:name, member_ids: [])
  end

  def set_group
    @group = Group.find(params[:id])
  end

  def correct_user
    unless @group.user_id == current_user.id
      redirect_to groups_path, alert: "このグループを編集・削除する権限がありません"
    end
  end
end
