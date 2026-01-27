class VacationRequest < ApplicationRecord
  belongs_to :user
  belongs_to :approved_by, class_name: "User", optional: true
  belongs_to :rejected_by, class_name: "User", optional: true

  enum status: { pending: 0, approved: 1, rejected: 2, canceled: 3 }

  validates :start_date, :end_date, presence: true
  validate :end_date_not_before_start
  validate :max_duration
  validate :remaining_days_available

  after_commit :notify_admins_on_create, on: :create

  scope :visible_to, ->(viewer) do
    return all if viewer.admin?
    joins(:user).where(users: { role: viewer.role })
  end

  scope :overlapping, ->(start_date, end_date) {
    where("start_date <= ? AND end_date >= ?", end_date, start_date)
  }

  def period_label
    return "" if start_date.blank? || end_date.blank?

    "#{start_date.strftime('%d/%m/%Y')} a #{end_date.strftime('%d/%m/%Y')}"
  end

  def duration_days
    return 0 if start_date.blank? || end_date.blank?

    (end_date - start_date).to_i + 1
  end

  def status_label
    case status
    when "pending" then "Pendente"
    when "approved" then "Aprovado"
    when "rejected" then "Recusado"
    when "canceled" then "Cancelado"
    else status
    end
  end

  private

  def end_date_not_before_start
    return if start_date.blank? || end_date.blank?

    errors.add(:end_date, "deve ser depois da data inicial") if end_date < start_date
  end

  def max_duration
    return if start_date.blank? || end_date.blank?

    errors.add(:end_date, "nao pode ultrapassar 20 dias") if duration_days > 20
  end

  def remaining_days_available
    return if start_date.blank? || end_date.blank?

    remaining = user.vacation_days_remaining(start_date.year, exclude_request_id: id)
    if duration_days > remaining
      errors.add(:base, "voce tem apenas #{remaining} dias de ferias disponiveis")
    end
  end

  def notify_admins_on_create
    NotifyAdminsVacationRequestJob.perform_later(id)
  end
end
