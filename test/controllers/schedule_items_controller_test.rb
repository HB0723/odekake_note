require "test_helper"

class ScheduleItemsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    @outing = outings(:one)                 # 自分の日帰りおでかけ
    @item = schedule_items(:one)            # @outing の予定
    @other_outing = outings(:two)           # 他ユーザーのおでかけ
    @other_item = schedule_items(:two)      # 他ユーザーの予定
    @my_other_outing = outings(:three)      # 自分の別のおでかけ
    @my_other_item = schedule_items(:three) # 自分の別のおでかけの予定
    sign_in @user
  end

  # --- 自分のおでかけ配下の操作 ---

  test "未ログインならログイン画面へ移動する" do
    sign_out @user
    get new_outing_schedule_item_url(@outing)
    assert_redirected_to new_user_session_url
  end

  test "予定の追加画面を表示できる" do
    get new_outing_schedule_item_url(@outing)
    assert_response :success
  end

  test "予定を追加できる" do
    assert_difference("@outing.schedule_items.count") do
      post outing_schedule_items_url(@outing), params: { schedule_item: { title: "ランチ", starts_at: "12:00", day_number: 1 } }
    end
    assert_redirected_to outing_url(@outing)
  end

  test "outing_id を送っても他のおでかけには追加できない" do
    assert_no_difference("@other_outing.schedule_items.count") do
      post outing_schedule_items_url(@outing), params: { schedule_item: { title: "ランチ", day_number: 1, outing_id: @other_outing.id } }
    end
  end

  test "タイトルが空なら追加できない" do
    assert_no_difference("ScheduleItem.count") do
      post outing_schedule_items_url(@outing), params: { schedule_item: { title: "", day_number: 1 } }
    end
    assert_response :unprocessable_content
  end

  test "日数の範囲外の day_number では追加できない" do
    assert_no_difference("ScheduleItem.count") do
      post outing_schedule_items_url(@outing), params: { schedule_item: { title: "ランチ", day_number: 2 } }
    end
    assert_response :unprocessable_content
    assert_select "li", text: /日程の範囲内で選んでください/
  end

  test "予定の編集画面を表示できる" do
    get edit_outing_schedule_item_url(@outing, @item)
    assert_response :success
  end

  test "予定を更新できる" do
    patch outing_schedule_item_url(@outing, @item), params: { schedule_item: { title: "更新後" } }
    assert_redirected_to outing_url(@outing)
    assert_equal "更新後", @item.reload.title
  end

  test "予定を削除できる" do
    assert_difference("ScheduleItem.count", -1) do
      delete outing_schedule_item_url(@outing, @item)
    end
    assert_redirected_to outing_url(@outing)
  end

  # --- 他ユーザーのおでかけ配下は404（1テスト1リクエスト） ---

  test "他ユーザーのおでかけ配下の追加画面(new)は開けない（404）" do
    get new_outing_schedule_item_url(@other_outing)
    assert_response :not_found
  end

  test "他ユーザーのおでかけ配下には予定を追加できない（create・404）" do
    assert_no_difference("ScheduleItem.count") do
      post outing_schedule_items_url(@other_outing), params: { schedule_item: { title: "侵入", day_number: 1 } }
    end
    assert_response :not_found
  end

  test "他ユーザーの予定の編集画面(edit)は開けない（404）" do
    get edit_outing_schedule_item_url(@other_outing, @other_item)
    assert_response :not_found
  end

  test "他ユーザーの予定は更新できない（update・404）" do
    patch outing_schedule_item_url(@other_outing, @other_item), params: { schedule_item: { title: "乗っ取り" } }
    assert_response :not_found
    assert_not_equal "乗っ取り", @other_item.reload.title
  end

  test "他ユーザーの予定は削除できない（destroy・404）" do
    assert_no_difference("ScheduleItem.count") do
      delete outing_schedule_item_url(@other_outing, @other_item)
    end
    assert_response :not_found
  end

  # --- 別のおでかけの予定を、違うおでかけのURLで開く（自分のデータ同士でも404） ---

  test "別のおでかけの予定を違うおでかけのURLで編集しようとすると404" do
    get edit_outing_schedule_item_url(@outing, @my_other_item)
    assert_response :not_found
  end

  test "別のおでかけの予定を違うおでかけのURLで更新しようとすると404" do
    patch outing_schedule_item_url(@outing, @my_other_item), params: { schedule_item: { title: "書き換え" } }
    assert_response :not_found
    assert_not_equal "書き換え", @my_other_item.reload.title
  end

  test "別のおでかけの予定を違うおでかけのURLで削除しようとすると404" do
    assert_no_difference("ScheduleItem.count") do
      delete outing_schedule_item_url(@outing, @my_other_item)
    end
    assert_response :not_found
  end
end
