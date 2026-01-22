VacationRequest.delete_all
User.delete_all

def ensure_user(email:, role:, approved: true)
  user = User.find_or_initialize_by(email: email)
  user.password = "password"
  user.password_confirmation = "password"
  user.role = role == :admin ? :escritorio : role
  user.approved = approved
  user.save!
  user.update!(role: role) if role == :admin
  user
end

def ensure_request(user:, start_date:, end_date:, status:)
  VacationRequest.find_or_create_by!(
    user: user,
    start_date: start_date,
    end_date: end_date,
    status: VacationRequest.statuses.fetch(status)
  )
end

admin_users = [
  { email: "jeffersonoliveira1212@gmail.com", first_name: "Ana", last_name: "Admin" },
  { email: "admin2@app.com", first_name: "Carlos", last_name: "Gomes" },
  { email: "admin3@app.com", first_name: "Patricia", last_name: "Santos" },
  { email: "admin4@app.com", first_name: "Diego", last_name: "Lima" }
]

admins = admin_users.map do |admin|
  user = ensure_user(email: admin[:email], role: :admin, approved: true)
  user.update!(first_name: admin[:first_name], last_name: admin[:last_name])
  user
end

escritorio_1 = ensure_user(email: "escritorio1@app.com", role: :escritorio, approved: true)
escritorio_1.update!(first_name: "Paulo", last_name: "Silva")
escritorio_2 = ensure_user(email: "escritorio2@app.com", role: :escritorio, approved: true)
escritorio_2.update!(first_name: "Marina", last_name: "Souza")

gerente_1 = ensure_user(email: "gerente1@app.com", role: :gerentes, approved: true)
gerente_1.update!(first_name: "Carla", last_name: "Lima")
gerente_2 = ensure_user(email: "gerente2@app.com", role: :gerentes, approved: true)
gerente_2.update!(first_name: "Bruno", last_name: "Alves")

seguranca_1 = ensure_user(email: "seguranca1@app.com", role: :seguranca, approved: true)
seguranca_1.update!(first_name: "Rafael", last_name: "Moraes")
seguranca_2 = ensure_user(email: "seguranca2@app.com", role: :seguranca, approved: true)
seguranca_2.update!(first_name: "Larissa", last_name: "Pereira")

ensure_request(user: escritorio_1, start_date: Date.new(2026, 2, 3), end_date: Date.new(2026, 2, 10), status: :approved)
ensure_request(user: escritorio_2, start_date: Date.new(2026, 5, 8), end_date: Date.new(2026, 5, 15), status: :pending)

ensure_request(user: gerente_1, start_date: Date.new(2026, 3, 12), end_date: Date.new(2026, 3, 18), status: :approved)
ensure_request(user: gerente_2, start_date: Date.new(2026, 9, 5), end_date: Date.new(2026, 9, 12), status: :pending)

ensure_request(user: seguranca_1, start_date: Date.new(2026, 7, 1), end_date: Date.new(2026, 7, 8), status: :approved)
ensure_request(user: seguranca_2, start_date: Date.new(2026, 11, 18), end_date: Date.new(2026, 11, 25), status: :pending)

ensure_request(user: admins.first, start_date: Date.new(2026, 4, 20), end_date: Date.new(2026, 4, 24), status: :approved)
