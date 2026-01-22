class NotifyAdminsNewUserJob < ApplicationJob
  queue_as :default

  def perform(user_id)
    user = User.find_by(id: user_id)
    return unless user

    admin_emails = User.admin.pluck(:email)
    return if admin_emails.empty?

    AdminNotifierMailer.new_user_pending(user, admin_emails).deliver_now
  end
end
