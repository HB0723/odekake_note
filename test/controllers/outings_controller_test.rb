require "test_helper"

class OutingsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    @outing = outings(:one)
    @other_outing = outings(:two)
    sign_in @user
  end

  test "未ログインならログイン画面へ移動する" do
    sign_out @user
    get outings_url
    assert_redirected_to new_user_session_url
  end

  test "一覧には自分のおでかけだけが表示される" do
    get outings_url
    assert_response :success
    assert_select "#outings", text: /#{@outing.title}/
    assert_select "#outings", text: /#{@other_outing.title}/, count: 0
  end

  test "新規登録画面を表示できる" do
    get new_outing_url
    assert_response :success
  end

  test "おでかけを登録できる（所有者はログインユーザー）" do
    assert_difference("@user.outings.count") do
      post outings_url, params: { outing: { title: "海", start_on: "2026-11-01", place: "江ノ島", memo: "" } }
    end
    assert_redirected_to outing_url(Outing.order(:id).last)
  end

  test "user_id を送っても他人のおでかけとして登録できない" do
    other = users(:two)
    assert_no_difference("other.outings.count") do
      post outings_url, params: { outing: { title: "海", start_on: "2026-11-01", user_id: other.id } }
    end
  end

  test "タイトルが空なら登録できない" do
    assert_no_difference("Outing.count") do
      post outings_url, params: { outing: { title: "", start_on: "2026-11-01" } }
    end
    assert_response :unprocessable_content
  end

  test "詳細画面を表示できる" do
    get outing_url(@outing)
    assert_response :success
  end

  test "編集画面を表示できる" do
    get edit_outing_url(@outing)
    assert_response :success
  end

  test "おでかけを更新できる" do
    patch outing_url(@outing), params: { outing: { title: "更新後" } }
    assert_redirected_to outing_url(@outing)
    assert_equal "更新後", @outing.reload.title
  end

  test "おでかけを削除できる" do
    assert_difference("Outing.count", -1) do
      delete outing_url(@outing)
    end
    assert_redirected_to outings_url
  end

  test "詳細画面に予定が表示される" do
    get outing_url(@outing)
    assert_select "li", text: /京都駅に集合/
  end

  test "日程範囲外になった予定は「日程範囲外」にまとめて表示される" do
    @outing.schedule_items.build(day_number: 3, title: "範囲外の予定").save!(validate: false)

    get outing_url(@outing)
    assert_select "h3", text: "日程範囲外"
    assert_select "li", text: /範囲外の予定/
  end

  test "他ユーザーのおでかけは表示できない（404）" do
    get outing_url(@other_outing)
    assert_response :not_found
  end

  test "他ユーザーのおでかけは編集画面を開けない（404）" do
    get edit_outing_url(@other_outing)
    assert_response :not_found
  end

  test "他ユーザーのおでかけは更新できない（404）" do
    patch outing_url(@other_outing), params: { outing: { title: "乗っ取り" } }
    assert_response :not_found
    assert_not_equal "乗っ取り", @other_outing.reload.title
  end

  test "他ユーザーのおでかけは削除できない（404）" do
    assert_no_difference("Outing.count") do
      delete outing_url(@other_outing)
    end
    assert_response :not_found
  end
end
