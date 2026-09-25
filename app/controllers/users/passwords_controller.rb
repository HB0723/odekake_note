class Users::PasswordsController < Devise::PasswordsController
  before_action :ensure_normal_user, only: :create

  private
    # ゲストユーザーのパスワード再設定メールは送らない
    def ensure_normal_user
      email = params.dig(:user, :email).to_s.strip.downcase
      return unless email == User::GUEST_EMAIL

      redirect_to new_user_session_path, alert: "ゲストユーザーのパスワードは再設定できません。", status: :see_other
    end
end
