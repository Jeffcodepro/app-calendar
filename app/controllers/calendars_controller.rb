class CalendarsController < ApplicationController
  def show
    @current_month = calendar_month
    @calendar_days = calendar_days(@current_month)
    @vacation_request = VacationRequest.new(
      start_date: params[:start_date],
      end_date: params[:end_date]
    )
    reference_year = (@vacation_request.start_date || Date.current).year
    @remaining_vacation_days = current_user.vacation_days_remaining(reference_year)
    base_scope = VacationRequest
                 .includes(:user)
                 .joins(:user)
                 .overlapping(@current_month.beginning_of_month, @current_month.end_of_month)

    if current_user.admin?
      @vacation_requests = base_scope.where(status: [:pending, :approved])
    else
      rejected_scope = base_scope
                       .where(user: current_user, status: :rejected)
                       .where("vacation_requests.updated_at >= ?", 1.day.ago)
      @vacation_requests = base_scope
                           .where(users: { role: User.roles.fetch(current_user.role) })
                           .where(status: [:pending, :approved])
                           .or(rejected_scope)
    end
  end

  private

  def calendar_month
    month = params[:month].to_i
    year = params[:year].to_i
    if month.positive? && year.positive?
      Date.new(year, month, 1)
    else
      Date.current.beginning_of_month
    end
  end

  def calendar_days(month_date)
    start_date = month_date.beginning_of_month.beginning_of_week(:sunday)
    end_date = month_date.end_of_month.end_of_week(:sunday)
    (start_date..end_date).to_a
  end
end
