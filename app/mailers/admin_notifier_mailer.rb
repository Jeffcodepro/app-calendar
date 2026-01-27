class AdminNotifierMailer < ApplicationMailer
  default from: ENV.fetch("DEFAULT_FROM_EMAIL", "no-reply@app-calendar.local")

  def new_user_pending(user, admin)
    @user = user
    @admin = admin
    token = email_action_token(action: "approve_user", user_id: @user.id, admin_id: @admin.id)
    @approve_url = admin_email_approve_user_url(token: token)
    @admin_panel_url = admin_users_url
    mail(to: @admin.email, subject: "Novo cadastro pendente")
  end

  def vacation_request_created(request, admin)
    @request = request
    @admin = admin
    approve_token = email_action_token(action: "approve_vacation_request", request_id: @request.id, admin_id: @admin.id)
    reject_token = email_action_token(action: "reject_vacation_request", request_id: @request.id, admin_id: @admin.id)
    @approve_url = admin_email_approve_vacation_request_url(token: approve_token)
    @reject_url = admin_email_reject_vacation_request_url(token: reject_token)
    @admin_panel_url = admin_users_url
    mail(to: @admin.email, subject: "Nova solicitacao de ferias")
  end

  private

  def email_action_token(payload)
    Rails.application.message_verifier(:admin_email_actions).generate(
      payload.merge(exp: 7.days.from_now.to_i)
    )
  end
end
