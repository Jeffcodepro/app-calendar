class Admin::UsersController < Admin::BaseController

  def index
    @pending_users = User.where(approved: false).order(created_at: :asc)
    @active_users  = User.where(approved: true).order(created_at: :asc)
    @pending_vacation_requests = VacationRequest
                                 .pending
                                 .includes(:user)
                                 .order(start_date: :asc)
    @history_page = page_param(:history_page)
    @active_page = page_param(:active_page)
    per_page = 10

    history_scope = VacationRequest
                    .approved
                    .includes(:user)
                    .order(end_date: :desc)
    @vacation_history_total_pages = total_pages(history_scope.count, per_page)
    @vacation_history = history_scope
                        .offset((@history_page - 1) * per_page)
                        .limit(per_page)

    active_scope = User.where(approved: true).order(created_at: :asc)
    @active_users_total_pages = total_pages(active_scope.count, per_page)
    @active_users = active_scope
                    .offset((@active_page - 1) * per_page)
                    .limit(per_page)
  end

  def edit
    @user = User.find(params[:id])
  end

  def update
    @user = User.find(params[:id])
    if @user.update(user_params)
      redirect_to admin_users_path, notice: "Usuário atualizado."
    else
      render :edit, status: :unprocessable_content
    end
  end

  def approve
    @user = User.find(params[:id])
    @user.update!(approved: true)
    redirect_to admin_users_path, notice: "Usuário aprovado."
  end

  def destroy
    @user = User.find(params[:id])
    @user.destroy
    redirect_to admin_users_path, notice: "Usuário removido."
  end

  def export_vacation_history
    begin
      require "caxlsx"
    rescue LoadError
      redirect_to admin_users_path, alert: "Exportacao indisponivel. Reinicie o servidor com bundle exec."
      return
    end

    history = VacationRequest
              .approved
              .includes(:user)
              .order(end_date: :desc)

    package = Axlsx::Package.new
    package.workbook.add_worksheet(name: "Historico") do |sheet|
      sheet.add_row ["Usuario", "Periodo", "Encerrado em", "Status"]
      history.each do |request|
        sheet.add_row [
          request.user.display_name,
          request.period_label,
          request.end_date.strftime("%d/%m/%Y"),
          request.status_label
        ]
      end
    end

    send_data package.to_stream.read,
              filename: "historico-ferias.xlsx",
              type: "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
  end

  private

  def user_params
    params.require(:user).permit(:role, :password, :password_confirmation)
  end

  def page_param(key)
    value = params.fetch(key, 1).to_i
    value < 1 ? 1 : value
  end

  def total_pages(count, per_page)
    (count / per_page.to_f).ceil
  end
end
