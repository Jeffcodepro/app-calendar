import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    this.key =
      this.data.get("key") ||
      `scroll:${window.location.pathname}${window.location.search}`
    this.saveScroll = this.saveScroll.bind(this)
    this.restoreScroll = this.restoreScroll.bind(this)

    document.addEventListener("turbo:before-visit", this.saveScroll)
    document.addEventListener("turbo:before-fetch-request", this.saveScroll)
    document.addEventListener("turbo:load", this.restoreScroll)

    this.restoreScroll()
  }

  disconnect() {
    document.removeEventListener("turbo:before-visit", this.saveScroll)
    document.removeEventListener("turbo:before-fetch-request", this.saveScroll)
    document.removeEventListener("turbo:load", this.restoreScroll)
  }

  saveScroll() {
    window.sessionStorage.setItem(this.key, String(window.scrollY))
  }

  restoreScroll() {
    const stored = window.sessionStorage.getItem(this.key)
    if (stored === null) return
    window.sessionStorage.removeItem(this.key)
    const y = Number.parseInt(stored, 10)
    window.requestAnimationFrame(() => window.scrollTo(0, Number.isNaN(y) ? 0 : y))
  }
}
