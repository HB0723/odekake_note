require "test_helper"

class Users::GuestSignInTest < ActionDispatch::IntegrationTest
  # --- ゲストログイン ---

  test "ゲストとしてログインでき、デモデータが作られる" do
    post users_guest_sign_in_url

    assert_redirected_to outings_url
    guest = User.find_by!(email: User::GUEST_EMAIL)
    assert_equal 3, guest.outings.count

    follow_redirect!
    assert_response :success
    assert_select "nav", text: /ゲストとしてログイン中/
  end

  test "再ログインするとゲストの変更はリセットされる" do
    post users_guest_sign_in_url
    guest = User.find_by!(email: User::GUEST_EMAIL)
    guest.outings.create!(title: "ゲストが追加", start_on: Date.current)
    sign_out guest

    post users_guest_sign_in_url

    assert_not guest.outings.exists?(title: "ゲストが追加")
    assert_equal 3, guest.outings.count
  end

  test "ログイン画面と新規登録画面にゲストログインボタンがある" do
    get new_user_session_url
    assert_select "form[action=?] button", users_guest_sign_in_path, text: "ゲストとしてログイン"

    get new_user_registration_url
    assert_select "form[action=?] button", users_guest_sign_in_path, text: "ゲストとしてログイン"
  end

  # --- ゲストの制限 ---

  test "ゲストはメールアドレス・パスワードを変更できない" do
    guest = User.guest
    guest.update!(password: "password") # 制限が無ければ更新が通る状態にしておく
    sign_in guest

    patch user_registration_url, params: {
      user: { email: "changed@example.com", password: "newpassword", password_confirmation: "newpassword", current_password: "password" }
    }

    assert_redirected_to outings_url
    assert_equal User::GUEST_EMAIL, guest.reload.email
    assert guest.valid_password?("password")
  end

  test "ゲストのアカウント編集画面には変更フォームと退会ボタンを出さない" do
    sign_in User.guest

    get edit_user_registration_url

    assert_response :success
    assert_select "p", text: /ゲストユーザーはメールアドレス・パスワードの変更や退会はできません/
    assert_select "form[action=?]", user_registration_path, count: 0
  end

  test "通常ユーザーのアカウント編集画面には変更フォームと退会ボタンがある" do
    sign_in users(:one)

    get edit_user_registration_url

    assert_response :success
    assert_select "form[action=?] input[name=_method][value=put]", user_registration_path
    assert_select "form[action=?] input[name=_method][value=delete]", user_registration_path
  end

  test "ゲストは退会できない" do
    sign_in User.guest

    assert_no_difference("User.count") do
      delete user_registration_url
    end
    assert_redirected_to outings_url
  end

  test "通常ユーザーは退会できる" do
    sign_in users(:one)

    assert_difference("User.count", -1) do
      delete user_registration_url
    end
  end

  test "ゲストのパスワード再設定メールは送らない" do
    User.guest

    assert_no_emails do
      post user_password_url, params: { user: { email: " GUEST@example.com " } }
    end
    assert_redirected_to new_user_session_url
  end

  test "通常ユーザーはパスワード再設定メールを受け取れる" do
    assert_emails 1 do
      post user_password_url, params: { user: { email: users(:one).email } }
    end
  end
end
