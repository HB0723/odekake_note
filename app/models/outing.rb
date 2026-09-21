class Outing < ApplicationRecord
  belongs_to :user
  has_many :schedule_items, dependent: :destroy

  validates :title, presence: true, length: { maximum: 50 }
  validates :start_on, presence: true
  validates :place, length: { maximum: 100 }
  validates :memo, length: { maximum: 500 }
  validate :end_on_not_before_start_on

  # 日数。終了日が空（日帰り）なら1日
  def day_count
    return 1 if start_on.blank? || end_on.blank?

    (end_on - start_on).to_i + 1
  end

  # n日目の日付
  def date_for(day_number)
    start_on + (day_number - 1)
  end

  private
    # 終了日は任意（空なら日帰り）。入力されている場合は開始日以降であること
    def end_on_not_before_start_on
      return if start_on.blank? || end_on.blank?

      errors.add(:end_on, :before_start_on) if end_on < start_on
    end
end
