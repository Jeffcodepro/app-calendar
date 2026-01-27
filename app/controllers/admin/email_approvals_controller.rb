module Admin
  class EmailApprovalsController < ApplicationController
    skip_before_action :authenticate_user!

    def approve_user
      payload = verify_email_action!(params[:token], expected_action: "approve_user")
      user = User.find(payload.fetch("user_id"))
      admin = User.find(payload.fetch("admin_id"))

      unless admin.admin?
        @message = "Aprovador invalido."
        return
      end

      if user.approved?
        @message = "Este usuario ja estava aprovado."
      else
        user.update!(approved: true, approved_by: admin)
        UserNotifierMailer.user_approved(user).deliver_later
        @message = "Usuario aprovado com sucesso."
      end
      @panel_url = admin_users_path
    rescue ActiveSupport::MessageVerifier::InvalidSignature
      @message = "Link de aprovacao invalido ou expirado."
    end

    def approve_vacation_request
      handle_vacation_update(:approved, "Solicitacao aprovada com sucesso.")
    end

    def reject_vacation_request
      handle_vacation_update(:rejected, "Solicitacao recusada com sucesso.")
    end

    private

    def handle_vacation_update(status, success_message)
      payload = verify_email_action!(params[:token], expected_action: status == :approved ? "approve_vacation_request" : "reject_vacation_request")
      request = VacationRequest.find(payload.fetch("request_id"))
      admin = User.find(payload.fetch("admin_id"))

      unless admin.admin?
        @message = "Aprovador invalido."
        return
      end

      if request.status != "pending"
        @message = "Esta solicitacao ja foi processada."
      else
        if status == :approved
          request.update!(status: status, approved_by: admin)
        else
          request.update!(status: status, rejected_by: admin)
        end
        if status == :approved
          UserNotifierMailer.vacation_request_approved(request).deliver_later
        else
          UserNotifierMailer.vacation_request_rejected(request).deliver_later
        end
        @message = success_message
      end
      @panel_url = admin_users_path
    rescue ActiveSupport::MessageVerifier::InvalidSignature
      @message = "Link de aprovacao invalido ou expirado."
    end

    def verify_email_action!(token, expected_action:)
      payload = Rails.application.message_verifier(:admin_email_actions).verify(token)
      raise ActiveSupport::MessageVerifier::InvalidSignature unless payload["action"] == expected_action
      raise ActiveSupport::MessageVerifier::InvalidSignature if payload["exp"].to_i < Time.current.to_i
      payload
    end
  end
end
