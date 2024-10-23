class EventsController < ApplicationController
  before_action :authenticate_user!, only:[:new, :create]
  def new
    @event = Event.new
  end

  def create
    @event = current_user.events.build(event_params)
    if @event.save
      redirect_to @event, notice: 'イベントが作成されました'
    else
      render :new
    end
  end

  private

  def event_params
    params.require(:event).permit(:name, :date, :location, :capacity, :visibility, :group_id, :description)
  end
end
