class NotifyAdminsVacationRequestJob < ApplicationJob
  queue_as :default

  def perform(request_id)
    request = VacationRequest.find_by(id: request_id)
    return unless request

    admin_emails = User.admin.pluck(:email)
    return if admin_emails.empty?

    AdminNotifierMailer.vacation_request_created(request, admin_emails).deliver_now
  end
end
