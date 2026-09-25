class PackingItem < ApplicationRecord
  belongs_to :outing

  validates :title, presence: true, length: { maximum: 50 }

  # 持ち物は作成順で十分
  scope :ordered, -> { order(:id) }
end
