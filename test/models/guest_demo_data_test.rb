require "test_helper"

class GuestDemoDataTest < ActiveSupport::TestCase
  setup do
    @guest = User.guest
  end

  test "デモデータを作成する" do
    GuestDemoData.reset!(@guest)

    assert_equal 3, @guest.outings.count
    assert_equal 11, ScheduleItem.joins(:outing).where(outings: { user_id: @guest.id }).count
    assert_equal 10, PackingItem.joins(:outing).where(outings: { user_id: @guest.id }).count
  end

  test "2回実行しても件数は変わらない（作り直される）" do
    GuestDemoData.reset!(@guest)
    GuestDemoData.reset!(@guest)

    assert_equal 3, @guest.outings.count
    assert_equal 11, ScheduleItem.joins(:outing).where(outings: { user_id: @guest.id }).count
    assert_equal 10, PackingItem.joins(:outing).where(outings: { user_id: @guest.id }).count
  end

  test "ゲストが追加・変更した内容はリセットで消える" do
    GuestDemoData.reset!(@guest)
    @guest.outings.create!(title: "ゲストが追加", start_on: Date.current)

    GuestDemoData.reset!(@guest)

    assert_not @guest.outings.exists?(title: "ゲストが追加")
  end

  test "おでかけの日付はリセット日からの相対日付になる" do
    GuestDemoData.reset!(@guest)

    hokkaido = @guest.outings.find_by!(title: "北海道 2泊3日")
    assert_equal Date.current + 30, hokkaido.start_on
    assert_equal 3, hokkaido.day_count
  end

  test "他のユーザーのデータには影響しない" do
    assert_no_difference("users(:one).outings.count") do
      GuestDemoData.reset!(@guest)
    end
  end
end
