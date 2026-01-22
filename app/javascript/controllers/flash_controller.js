import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { timeout: { type: Number, default: 5000 } }

  connect() {
    this.timeoutId = setTimeout(() => {
      this.element.classList.remove("show")
      setTimeout(() => this.element.remove(), 200)
    }, this.timeoutValue)
  }

  disconnect() {
    if (this.timeoutId) {
      clearTimeout(this.timeoutId)
    }
  }
}
