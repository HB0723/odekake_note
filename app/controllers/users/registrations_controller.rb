class Users::RegistrationsController < Devise::RegistrationsController
  before_action :ensure_normal_user, only: %i[ update destroy ]

  private
    # ゲストユーザーはメールアドレス・パスワードの変更と退会をできない（共用アカウントのため）
    def ensure_normal_user
      return unless resource.guest?

      redirect_to outings_path, alert: "ゲストユーザーは変更・削除できません。", status: :see_other
    end
end
