require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "User.guest はゲストユーザーを作成する" do
    assert_difference("User.count", 1) do
      assert_equal User::GUEST_EMAIL, User.guest.email
    end
  end

  test "User.guest を2回呼んでも同じユーザーを返す" do
    guest = User.guest
    assert_no_difference("User.count") do
      assert_equal guest, User.guest
    end
  end

  test "guest? はゲストユーザーだけ true" do
    assert User.guest.guest?
    assert_not users(:one).guest?
  end
end
