# エラーのある入力欄は、Rails 標準の <div class="field_with_errors"> で囲まず、
# Bootstrap の is-invalid クラスを付けて赤枠で表示する（ラベルはそのまま）
ActionView::Base.field_error_proc = proc do |html_tag, _instance|
  fragment = Nokogiri::HTML::DocumentFragment.parse(html_tag)
  element = fragment.children.first

  if element && %w[input select textarea].include?(element.name) && element["type"] != "hidden"
    element.add_class("is-invalid")
    fragment.to_html.html_safe
  else
    html_tag
  end
end
