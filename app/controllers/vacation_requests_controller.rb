class VacationRequestsController < ApplicationController
  before_action :set_vacation_request, only: [:destroy, :cancel]

  def index
    @vacation_requests = current_user.vacation_requests.order(start_date: :desc)
  end

  def create
    @vacation_request = current_user.vacation_requests.new(vacation_request_params)
    @vacation_request.status = :pending

    if @vacation_request.save
      redirect_to calendar_path, notice: "Solicitacao enviada para aprovacao."
    else
      redirect_to calendar_path, alert: @vacation_request.errors.full_messages.to_sentence
    end
  end

  def destroy
    @vacation_request.destroy
    redirect_to vacation_requests_path, notice: "Solicitacao removida."
  end

  def cancel
    @vacation_request.update(status: :canceled)
    redirect_to vacation_requests_path, notice: "Solicitacao cancelada."
  end

  private

  def set_vacation_request
    @vacation_request = current_user.vacation_requests.find(params[:id])
  end

  def vacation_request_params
    params.require(:vacation_request).permit(:start_date, :end_date)
  end
end
