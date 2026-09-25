import { Controller } from "@hotwired/stimulus"

// チェックボックスなどの変更時に、囲んでいるフォームを送信する
export default class extends Controller {
  submit() {
    this.element.requestSubmit()
  }
}
