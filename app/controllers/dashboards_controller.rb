class DashboardsController < ApplicationController
  def show
    # exemplo: próximas férias visíveis para o usuário
    @vacation_requests = VacationRequest.visible_to(current_user)
                                       .approved
                                       .where("start_date >= ?", Date.current)
                                       .order(start_date: :asc)
                                       .limit(5)

    # só admin vê pendências de aprovação de usuários
    @pending_users_count = current_user.admin? ? User.where(approved: false).count : 0

    @next_vacation = current_user.vacation_requests
                                 .approved
                                 .where("start_date >= ?", Date.current)
                                 .order(start_date: :asc)
                                 .first

    @vacation_countdown_days = if @next_vacation
                                 (@next_vacation.start_date - Date.current).to_i
                               end

    @vacation_duration_days = if @next_vacation
                                (@next_vacation.end_date - @next_vacation.start_date).to_i + 1
                              end

    @destinations_month = @next_vacation ? @next_vacation.start_date.month : 0
  end
end
