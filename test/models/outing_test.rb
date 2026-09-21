require "test_helper"

class OutingTest < ActiveSupport::TestCase
  def build_outing(**attrs)
    users(:one).outings.build({ title: "海", start_on: Date.new(2026, 11, 1) }.merge(attrs))
  end

  test "有効な属性なら保存できる（終了日なしは日帰り）" do
    assert build_outing.valid?
  end

  test "タイトルは必須" do
    outing = build_outing(title: nil)
    assert_not outing.valid?
    assert outing.errors.of_kind?(:title, :blank)
  end

  test "開始日は必須" do
    outing = build_outing(start_on: nil)
    assert_not outing.valid?
    assert outing.errors.of_kind?(:start_on, :blank)
  end

  test "タイトルは50文字まで" do
    assert build_outing(title: "あ" * 50).valid?

    outing = build_outing(title: "あ" * 51)
    assert_not outing.valid?
    assert outing.errors.of_kind?(:title, :too_long)
  end

  test "メモは500文字まで" do
    assert build_outing(memo: "あ" * 500).valid?

    outing = build_outing(memo: "あ" * 501)
    assert_not outing.valid?
    assert outing.errors.of_kind?(:memo, :too_long)
  end

  test "終了日が開始日と同じ日なら有効" do
    assert build_outing(end_on: Date.new(2026, 11, 1)).valid?
  end

  test "終了日が開始日より後なら有効" do
    assert build_outing(end_on: Date.new(2026, 11, 3)).valid?
  end

  test "終了日が開始日より前だと無効で、日本語のエラーメッセージが出る" do
    outing = build_outing(end_on: Date.new(2026, 10, 31))
    assert_not outing.valid?
    assert outing.errors.of_kind?(:end_on, :before_start_on)
    assert_includes outing.errors.full_messages, "終了日は開始日以降の日付にしてください"
  end

  test "day_count は終了日が空なら1日" do
    assert_equal 1, build_outing.day_count
  end

  test "day_count は開始日と終了日が同じ日なら1日" do
    assert_equal 1, build_outing(end_on: Date.new(2026, 11, 1)).day_count
  end

  test "day_count は開始日から終了日までの日数" do
    assert_equal 3, build_outing(end_on: Date.new(2026, 11, 3)).day_count
  end

  test "date_for は n日目の日付を返す" do
    outing = build_outing(end_on: Date.new(2026, 11, 3))
    assert_equal Date.new(2026, 11, 1), outing.date_for(1)
    assert_equal Date.new(2026, 11, 3), outing.date_for(3)
  end

  test "ユーザーを削除するとおでかけも削除される" do
    user = users(:one)
    assert_difference("Outing.count", -user.outings.count) do
      user.destroy
    end
  end
end
