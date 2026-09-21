class ScheduleItem < ApplicationRecord
  belongs_to :outing

  validates :title, presence: true, length: { maximum: 50 }
  validates :memo, length: { maximum: 500 }
  validates :day_number, numericality: { only_integer: true, greater_than_or_equal_to: 1 }
  validate :day_number_within_outing

  # 日ごと → 時刻順 → 登録順。時間未定（starts_at が空）は各日の最後
  scope :chronological, -> {
    order(:day_number, Arel.sql("schedule_items.starts_at IS NULL"), :starts_at, :id)
  }

  private
    def day_number_within_outing
      return if outing.blank? || day_number.blank?

      errors.add(:day_number, :out_of_range) if day_number > outing.day_count
    end
end
