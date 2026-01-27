class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :timeoutable

  enum role: { escritorio: 0, gerentes: 1, seguranca: 2, admin: 3 }

  has_many :vacation_requests, dependent: :destroy
  belongs_to :approved_by, class_name: "User", optional: true

  def display_name
    full_name = [first_name, last_name].compact.join(" ").strip
    full_name.present? ? full_name : email
  end

  def role_label
    {
      "escritorio" => "Escritório",
      "gerentes" => "Gerentes",
      "seguranca" => "Segurança",
      "admin" => "Admin"
    }[role] || role
  end

  after_commit :notify_admins_on_signup, on: :create
  before_validation :normalize_names

  def vacation_days_used(year, exclude_request_id: nil)
    start_of_year = Date.new(year, 1, 1)
    end_of_year = Date.new(year, 12, 31)

    scope = vacation_requests.where(status: [:pending, :approved])
    scope = scope.where.not(id: exclude_request_id) if exclude_request_id

    scope.sum do |request|
      range_start = [request.start_date, start_of_year].max
      range_end = [request.end_date, end_of_year].min
      range_start > range_end ? 0 : (range_end - range_start).to_i + 1
    end
  end

  def vacation_days_remaining(year, exclude_request_id: nil)
    [20 - vacation_days_used(year, exclude_request_id: exclude_request_id), 0].max
  end

  # Segurança: ninguém vira admin por params (mesmo se tentar “hackear” request)
  validate :role_cannot_be_admin_on_signup, on: :create
  validate :email_must_be_valid
  validate :password_must_be_strong, if: -> { password.present? }

  def active_for_authentication?
    super && approved?
  end

  def inactive_message
    approved? ? super : :not_approved
  end

  private

  def role_cannot_be_admin_on_signup
    errors.add(:role, "inválida") if admin?
  end

  def email_must_be_valid
    return if email.blank?
    return if email.match?(URI::MailTo::EMAIL_REGEXP)

    errors.add(:email, "inválido")
  end

  def password_must_be_strong
    unless password.match?(/\A(?=.*[A-Za-z])(?=.*\d).{8,}\z/)
      errors.add(:password, "deve ter no mínimo 8 caracteres e conter letras e números")
    end
  end

  def notify_admins_on_signup
    return if approved?

    NotifyAdminsNewUserJob.perform_later(id)
  end

  def normalize_names
    self.first_name = first_name.to_s.strip.split.map(&:capitalize).join(" ") if first_name.present?
    self.last_name = last_name.to_s.strip.split.map(&:capitalize).join(" ") if last_name.present?
  end
end
