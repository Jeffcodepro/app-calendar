module Admin
  class VacationRequestsController < BaseController
    before_action :set_vacation_request, only: [:show, :destroy, :approve, :reject]

    def index
      @vacation_requests = VacationRequest.includes(:user).order(created_at: :desc)
    end

    def show
    end

    def destroy
      if @vacation_request.start_date <= Date.current
        redirect_to admin_users_path, alert: "Nao e possivel excluir ferias ja iniciadas."
        return
      end

      @vacation_request.destroy
      redirect_to admin_users_path, notice: "Solicitacao removida."
    end

    def approve
      @vacation_request.update(status: :approved)
      redirect_to admin_users_path, notice: "Solicitacao aprovada."
    end

    def reject
      @vacation_request.update(status: :rejected)
      redirect_to admin_users_path, notice: "Solicitacao recusada."
    end

    private

    def set_vacation_request
      @vacation_request = VacationRequest.find(params[:id])
    end
  end
end
