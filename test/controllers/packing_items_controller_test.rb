require "test_helper"

class PackingItemsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    @outing = outings(:one)                 # 自分のおでかけ
    @item = packing_items(:one)             # @outing の持ち物
    @other_outing = outings(:two)           # 他ユーザーのおでかけ
    @other_item = packing_items(:two)       # 他ユーザーの持ち物
    @my_other_outing = outings(:three)      # 自分の別のおでかけ
    @my_other_item = packing_items(:three)  # 自分の別のおでかけの持ち物
    sign_in @user
  end

  # --- チェックの切り替え ---

  test "未ログインならチェックを切り替えられない" do
    sign_out @user
    patch toggle_outing_packing_item_url(@outing, @item)
    assert_redirected_to new_user_session_url
    assert_not @item.reload.checked
  end

  test "Turbo Stream で行とカウント表示を差し替える" do
    patch toggle_outing_packing_item_url(@outing, @item), as: :turbo_stream

    assert_response :success
    assert_equal "text/vnd.turbo-stream.html", response.media_type
    assert @item.reload.checked
    assert_turbo_stream action: "replace", target: dom_id(@item)
    assert_turbo_stream action: "replace", target: "packing_items_summary" do
      assert_select "p", text: /1\/1 チェック済/
    end
  end

  test "2回切り替えると元に戻る" do
    2.times { patch toggle_outing_packing_item_url(@outing, @item), as: :turbo_stream }
    assert_not @item.reload.checked
  end

  test "HTML リクエストならおでかけ詳細へ戻る" do
    patch toggle_outing_packing_item_url(@outing, @item)
    assert_redirected_to outing_url(@outing)
    assert_response :see_other
    assert @item.reload.checked
  end

  # --- 他人・別のおでかけの持ち物 ---

  test "他ユーザーの持ち物は切り替えられない" do
    patch toggle_outing_packing_item_url(@other_outing, @other_item), as: :turbo_stream
    assert_response :not_found
    assert_not @other_item.reload.checked
  end

  test "自分の別のおでかけの持ち物は、このおでかけ経由では切り替えられない" do
    patch toggle_outing_packing_item_url(@outing, @my_other_item), as: :turbo_stream
    assert_response :not_found
    assert_not @my_other_item.reload.checked
  end
end
