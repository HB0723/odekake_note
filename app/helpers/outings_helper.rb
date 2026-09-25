module OutingsHelper
  # 終了日が空なら日帰りなので開始日のみ、あれば「開始日 〜 終了日」
  # スマホで日付の途中で改行されないよう、日付ごとに text-nowrap で囲む（改行は「〜」の後だけ）
  def outing_period(outing)
    start_tag = tag.span(l(outing.start_on, format: :long), class: "text-nowrap")
    return start_tag if outing.end_on.blank?

    safe_join([ start_tag, " 〜 ", tag.span(l(outing.end_on, format: :long), class: "text-nowrap") ])
  end

  # 「日帰り」「2泊3日」のような表記
  def outing_duration_label(outing)
    days = outing.day_count
    days == 1 ? "日帰り" : "#{days - 1}泊#{days}日"
  end
end
