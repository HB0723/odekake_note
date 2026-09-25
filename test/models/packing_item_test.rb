require "test_helper"

class PackingItemTest < ActiveSupport::TestCase
  test "持ち物名が空なら日本語のエラーメッセージになる" do
    item = outings(:one).packing_items.build(title: "")

    assert_not item.valid?
    assert_includes item.errors.full_messages, "持ち物名を入力してください"
  end
end
