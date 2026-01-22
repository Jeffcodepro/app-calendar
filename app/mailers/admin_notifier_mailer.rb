class AdminNotifierMailer < ApplicationMailer
  default from: ENV.fetch("DEFAULT_FROM_EMAIL", "no-reply@app-calendar.local")

  def new_user_pending(user, admin_emails)
    @user = user
    mail(to: admin_emails, subject: "Novo cadastro pendente")
  end

  def vacation_request_created(request, admin_emails)
    @request = request
    mail(to: admin_emails, subject: "Nova solicitacao de ferias")
  end
end
