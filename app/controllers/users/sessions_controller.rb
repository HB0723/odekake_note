class Users::SessionsController < Devise::SessionsController
  # ゲストとしてログインする。ログインのたびにデモデータを作り直す
  def guest_sign_in
    guest = User.guest
    GuestDemoData.reset!(guest)
    sign_in guest
    redirect_to outings_path, notice: "ゲストユーザーとしてログインしました。", status: :see_other
  end
end
