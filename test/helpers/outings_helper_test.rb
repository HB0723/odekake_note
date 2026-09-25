require "test_helper"

class OutingsHelperTest < ActionView::TestCase
  test "期間は日付ごとに改行されないよう囲む" do
    outing = Outing.new(start_on: Date.new(2026, 10, 25), end_on: Date.new(2026, 10, 27))
    html = outing_period(outing)

    assert_includes html, "〜"
    assert_equal 2, html.scan('class="text-nowrap"').size
  end

  test "日帰りは「日帰り」" do
    assert_equal "日帰り", outing_duration_label(Outing.new(start_on: Date.new(2026, 10, 1)))
  end

  test "複数日は「n泊m日」" do
    outing = Outing.new(start_on: Date.new(2026, 10, 1), end_on: Date.new(2026, 10, 3))
    assert_equal "2泊3日", outing_duration_label(outing)
  end
end
