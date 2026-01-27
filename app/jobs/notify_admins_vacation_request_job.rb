class NotifyAdminsVacationRequestJob < ApplicationJob
  queue_as :default

  def perform(request_id)
    request = VacationRequest.find_by(id: request_id)
    return unless request

    admins = User.admin.to_a
    return if admins.empty?

    admins.each do |admin|
      AdminNotifierMailer.vacation_request_created(request, admin).deliver_now
    end
  end
end
