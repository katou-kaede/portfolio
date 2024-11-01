class GroupsController < ApplicationController
  before_action :authenticate_user!

  def new
    @group = Group.new
    @group.group_members.build
    @friends = current_user.friends.includes(:profile)
  end

  def create
          Rails.logger.debug "Group params: #{group_params.inspect}"
    @group = current_user.groups.build(group_params)
    @group.user_id = current_user.id
    if @group.save
      Rails.logger.debug "Member IDs to be assigned: #{params[:group][:member_ids]}"

      @group.member_ids = params[:group][:member_ids]
      Rails.logger.debug "Assigned members after saving: #{@group.members.inspect}"
      Rails.logger.debug "Group saved successfully: #{@group.persisted?}"

      redirect_to groups_path, notice: 'グループが作成されました'
    else
      @friends = current_user.friends.includes(:profile)
      render :new, status: :unprocessable_entity, alert: 'グループ作成に失敗しました'
    end
  end

  def index
    @groups = current_user.groups.page(params[:page]).per(10)
  end

  private

  def group_params
    params.require(:group).permit(:name, member_ids: [])
  end
end
