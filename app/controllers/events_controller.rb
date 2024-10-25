class EventsController < ApplicationController
  before_action :authenticate_user!, only:[:new, :create, :update, :destroy, :toggle_registration]
  before_action :set_event, only: [:show, :edit, :update, :destroy, :toggle_registration, :toggle_participation]

  def index
    @events = Event.all.select(&:registration_open?)
  end

  def new
    @event = Event.new
  end

  def create
    @event = current_user.events.build(event_params)
    @event.user_id = current_user.id
    if @event.save
      redirect_to @event, notice: 'イベントが作成されました'
    else
      render :new
    end
  end

  def show
  end

  def edit
  end

  def destroy
  end

  def update
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
          flash[:alert] = "過去のイベントまたは定員に達したイベントのため、再開できません"
          render events_path
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
end
