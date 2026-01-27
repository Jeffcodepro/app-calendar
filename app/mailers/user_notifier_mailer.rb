class UserNotifierMailer < ApplicationMailer
  default from: ENV.fetch("DEFAULT_FROM_EMAIL", "no-reply@app-calendar.local")

  def user_approved(user)
    @user = user
    @dashboard_url = dashboard_url
    @calendar_url = calendar_url(grupo: @user.role)
    mail(to: @user.email, subject: "Seu cadastro foi aprovado")
  end

  def vacation_request_approved(request)
    @request = request
    @user = request.user
    @dashboard_url = dashboard_url
    mail(to: @user.email, subject: "Ferias aprovadas")
  end

  def vacation_request_rejected(request)
    @request = request
    @user = request.user
    @dashboard_url = dashboard_url
    mail(to: @user.email, subject: "Ferias recusadas")
  end
end
