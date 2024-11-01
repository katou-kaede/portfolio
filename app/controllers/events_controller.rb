class EventsController < ApplicationController
  before_action :authenticate_user!, only:[:new, :create, :edit, :update, :destroy, :toggle_registration]
  before_action :set_event, only: [:show, :edit, :update, :destroy, :toggle_registration, :toggle_participation]
  before_action :correct_user, only: [:edit, :update, :destroy]

  def index
    @events = Event.where(status: 'open').viewable_by(current_user).page(params[:page]).per(10)
    @events.each do |event|
      if !event.registration_open?
        event.update(status: 'closed')
      end
    end
  end

  def past_index
    @past_events = Event.where('date < ?', Time.current).viewable_by(current_user).order(date: :desc).page(params[:page]).per(10)
  end

  def new
    @event = Event.new
    @groups = Group.where(user_id: current_user.id).includes(:group_members)
  end

  def create
    @event = current_user.events.build(event_params)
    @event.user_id = current_user.id
    @event.group_id = nil if params[:event][:group_id] == 'all_friends'
    if @event.save
      redirect_to @event, notice: 'イベントが作成されました'
    else
      render :new
    end
  end

  def show
  end

  def edit
    @groups = Group.where(user_id: current_user.id).includes(:group_members)
  end

  def destroy
    @event.destroy
    redirect_to events_path, notice: 'イベントが削除されました'
  end

  def update
    @event.group_id = nil if params[:event][:group_id] == 'all_friends'
    if @event.update(event_params)
      @event.update_registration_status
      redirect_to  @event, notice: 'イベントが更新されました'
    else
      flash.now[:alert] = 'イベントの更新に失敗しました'
      render :edit
    end
  end

  def toggle_registration
    if @event.hosted_by?(current_user)
      if @event.registration_open?
        @event.close_registration
      else
        if @event.date.future? && (@event.capacity.nil? || @event.capacity > @event.participants.count)
          @event.open_registration
        else
          flash[:alert] = "過去のイベントのため再開できません"
          redirect_to request.referer || past_events_path and return
        end
      end
    end

    @button_container_id = "button_container_#{@event.id}"
    respond_to do |format|
      format.turbo_stream { render 'toggle_button' }
      format.html { redirect_to events_path }
    end
  end

  def toggle_participation
    if current_user.participating?(@event)
      current_user.leave_event(@event)
    else
      current_user.join_event(@event)
    end
    @button_container_id = "button_container_#{@event.id}"
    respond_to do |format|
      format.turbo_stream { render 'toggle_button' }
      format.html { redirect_to events_path }
    end
  end

  private

  def event_params
    params.require(:event).permit(:name, :date, :location, :capacity, :visibility, :group_id, :description)
  end

  def set_event
    @event = Event.find(params[:id])
  end

  def correct_user
    unless @event.hosted_by?(current_user)
      redirect_to events_path, alert: 'このイベントを編集・削除する権限がありません'
    end
  end
end
