require "test_helper"

class ScheduleItemTest < ActiveSupport::TestCase
  setup do
    @day_trip = outings(:one)   # 日帰り（1日）
    @multi_day = outings(:three) # 3日間
  end

  def build_item(outing = @day_trip, **attrs)
    outing.schedule_items.build({ title: "集合", day_number: 1 }.merge(attrs))
  end

  test "有効な属性なら保存できる（時刻は任意）" do
    assert build_item.valid?
    assert build_item(starts_at: nil).valid?
  end

  test "タイトルは必須" do
    item = build_item(title: nil)
    assert_not item.valid?
    assert item.errors.of_kind?(:title, :blank)
  end

  test "タイトルは50文字まで" do
    assert build_item(title: "あ" * 50).valid?
    assert_not build_item(title: "あ" * 51).valid?
  end

  test "メモは500文字まで" do
    assert build_item(memo: "あ" * 500).valid?
    assert_not build_item(memo: "あ" * 501).valid?
  end

  test "day_number は1以上" do
    item = build_item(day_number: 0)
    assert_not item.valid?
    assert item.errors.of_kind?(:day_number, :greater_than_or_equal_to)
  end

  test "日帰りのおでかけでは2日目以降を指定できない" do
    item = build_item(@day_trip, day_number: 2)
    assert_not item.valid?
    assert item.errors.of_kind?(:day_number, :out_of_range)
    assert_includes item.errors.full_messages, "何日目は日程の範囲内で選んでください"
  end

  test "複数日のおでかけでは最終日まで指定できる" do
    assert build_item(@multi_day, day_number: 3).valid?
  end

  test "複数日のおでかけでも日数を超える day_number は保存できない" do
    item = build_item(@multi_day, day_number: 4)
    assert_not item.valid?
    assert item.errors.of_kind?(:day_number, :out_of_range)
    assert_no_difference("ScheduleItem.count") { item.save }
  end

  test "chronological は日ごと・時刻順で、時間未定は各日の最後になる" do
    @multi_day.schedule_items.create!(day_number: 1, title: "自由時間")            # 時間未定（先に登録）
    @multi_day.schedule_items.create!(day_number: 1, title: "夕食", starts_at: "23:00")
    @multi_day.schedule_items.create!(day_number: 1, title: "早朝出発", starts_at: "00:30")
    @multi_day.schedule_items.create!(day_number: 1, title: "宿探し")              # 時間未定（後に登録）
    @multi_day.schedule_items.create!(day_number: 1, title: "観光", starts_at: "09:00")
    @multi_day.schedule_items.create!(day_number: 3, title: "帰宅")

    titles = @multi_day.schedule_items.chronological.map(&:title)

    assert_equal %w[ 早朝出発 観光 夕食 自由時間 宿探し 美術館へ行く 帰宅 ], titles
  end

  test "おでかけを削除すると予定も削除される" do
    assert_difference("ScheduleItem.count", -1) do
      @day_trip.destroy
    end
  end
end
