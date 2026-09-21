module OutingsHelper
  # 終了日が空なら日帰りなので開始日のみ、あれば「開始日 〜 終了日」
  def outing_period(outing)
    start_text = l(outing.start_on, format: :long)
    return start_text if outing.end_on.blank?

    "#{start_text} 〜 #{l(outing.end_on, format: :long)}"
  end
end
