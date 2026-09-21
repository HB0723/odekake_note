module ScheduleItemsHelper
  # 「2日目（10/11 土）」のような表記
  def day_label(outing, day_number)
    "#{day_number}日目（#{l(outing.date_for(day_number), format: "%-m/%-d %a")}）"
  end

  def day_options(outing)
    (1..outing.day_count).map { |n| [ day_label(outing, n), n ] }
  end

  def starts_at_label(schedule_item)
    schedule_item.starts_at ? schedule_item.starts_at.strftime("%H:%M") : "時間未定"
  end
end
