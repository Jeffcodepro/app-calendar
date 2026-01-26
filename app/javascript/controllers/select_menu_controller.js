import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["native", "button", "label", "list"]

  connect() {
    this.handleOutsideClick = this.handleOutsideClick.bind(this)
    this.handleEscape = this.handleEscape.bind(this)
    this.syncFromNative()
    document.addEventListener("click", this.handleOutsideClick)
    document.addEventListener("keydown", this.handleEscape)
  }

  disconnect() {
    document.removeEventListener("click", this.handleOutsideClick)
    document.removeEventListener("keydown", this.handleEscape)
  }

  toggle() {
    this.listTarget.classList.toggle("is-open")
    this.buttonTarget.setAttribute(
      "aria-expanded",
      this.listTarget.classList.contains("is-open")
    )
  }

  choose(event) {
    const value = event.currentTarget.dataset.value
    if (!value) return

    this.nativeTarget.value = value
    this.syncFromNative()
    this.close()
  }

  syncFromNative() {
    const option = this.nativeTarget.selectedOptions[0]
    if (option) this.labelTarget.textContent = option.textContent
  }

  close() {
    this.listTarget.classList.remove("is-open")
    this.buttonTarget.setAttribute("aria-expanded", "false")
  }

  handleOutsideClick(event) {
    if (!this.element.contains(event.target)) this.close()
  }

  handleEscape(event) {
    if (event.key === "Escape") this.close()
  }
}
