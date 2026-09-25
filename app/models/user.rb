class User < ApplicationRecord
  GUEST_EMAIL = "guest@example.com".freeze

  has_many :outings, dependent: :destroy

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  # ゲストユーザー（固定アカウント）。パスワードは作成時のランダム値で、誰にも知らせない
  def self.guest
    find_or_create_by!(email: GUEST_EMAIL) do |user|
      user.password = SecureRandom.urlsafe_base64
    end
  end

  def guest?
    email == GUEST_EMAIL
  end
end
