class NotifyAdminsNewUserJob < ApplicationJob
  queue_as :default

  def perform(user_id)
    user = User.find_by(id: user_id)
    return unless user

    admins = User.admin.to_a
    return if admins.empty?

    admins.each do |admin|
      AdminNotifierMailer.new_user_pending(user, admin).deliver_now
    end
  end
end
