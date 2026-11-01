class Admin::UsersController < Admin::BaseController
  before_action :set_user, only: %i[edit update destroy]

  def index
    authorize User
    scope = policy_scope(User).order(:last_name)
    scope = scope.where(role: params[:role]) if params[:role].present?
    if params[:q].present?
      q = "%#{User.sanitize_sql_like(params[:q])}%"
      scope = scope.where("last_name ILIKE :q OR first_name ILIKE :q OR email ILIKE :q OR organization_name ILIKE :q", q: q)
    end
    @pagy, @users = pagy(scope)
  end

  def new
    @user = User.new(role: :trainer)
    authorize @user
  end

  # Compte créé par l'équipe : mot de passe aléatoire, l'utilisateur le définit via le lien reçu.
  def create
    @user = User.new(user_params)
    authorize @user
    @user.password = SecureRandom.base58(16) + "Aa1"
    @user.terms_accepted_at = Time.current
    @user.skip_confirmation!
    if @user.save
      @user.send_reset_password_instructions
      redirect_to admin_users_path, notice: "Compte créé. #{@user.full_name} a reçu un lien pour définir son mot de passe."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit = authorize(@user)

  def update
    authorize @user
    if @user.update(user_params)
      redirect_to admin_users_path, notice: "Compte mis à jour."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    authorize @user
    if @user.destroy
      redirect_to admin_users_path, notice: "Compte supprimé."
    else
      redirect_to admin_users_path, alert: "Ce compte a un historique de formation : il est conservé (obligation de preuve)."
    end
  end

  private

  def set_user = @user = User.find(params[:id])

  def user_params
    permitted = %i[first_name last_name email job_title organization_name organization_type phone]
    permitted += %i[role reports_referent] if current_user.admin?
    params.require(:user).permit(permitted)
  end
end
