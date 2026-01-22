import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input"]

  toggle(event) {
    const show = event.target.checked
    this.inputTargets.forEach((input) => {
      input.type = show ? "text" : "password"
    })
  }
}
