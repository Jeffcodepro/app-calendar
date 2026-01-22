import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "day",
    "startDate",
    "endDate",
    "rangeLabel",
    "submitButton",
    "prevLink",
    "nextLink"
  ]
  static values = { remainingDays: Number }

  connect() {
    this.start = this.startDateTarget.value
    this.end = this.endDateTarget.value
    this.sync()
  }

  select(event) {
    const day = event.currentTarget
    if (day.dataset.disabled === "true") return

    const date = day.dataset.date

    if (!this.start || (this.start && this.end)) {
      this.start = date
      this.end = ""
    } else if (!this.end) {
      if (date < this.start) {
        this.start = date
      } else {
        this.end = date
      }
    }

    this.sync()
  }

  clear() {
    this.start = ""
    this.end = ""
    this.sync()
  }

  sync() {
    this.startDateTarget.value = this.start || ""
    this.endDateTarget.value = this.end || ""

    const label = this.rangeLabelTarget
    const rangeLength = this.rangeLength()
    const hasRange = this.start && this.end
    const exceedsLimit = hasRange && this.remainingDaysValue > 0 && rangeLength > this.remainingDaysValue

    if (!this.start) {
      label.textContent = "Nenhuma data selecionada ainda."
    } else if (!this.end) {
      label.textContent = `Inicio: ${this.formatDate(this.start)}. Selecione a data final.`
    } else if (exceedsLimit) {
      label.textContent = `Limite de ${this.remainingDaysValue} dias excedido.`
    } else {
      label.textContent = `Selecionado: ${this.formatDate(this.start)} ate ${this.formatDate(this.end)}.`
    }

    this.submitButtonTarget.disabled = !hasRange || exceedsLimit
    this.updateSelectionClasses()
    this.updateNavLinks()
  }

  updateSelectionClasses() {
    this.dayTargets.forEach((day) => {
      const date = day.dataset.date
      day.classList.remove("is-selected", "is-range-start", "is-range-end")

      if (!this.start) return

      if (this.start === date) {
        day.classList.add("is-selected", "is-range-start")
      }

      if (this.end === date) {
        day.classList.add("is-selected", "is-range-end")
      }

      if (this.start && this.end && date > this.start && date < this.end) {
        day.classList.add("is-selected")
      }
    })
  }

  rangeLength() {
    if (!this.start || !this.end) return 0

    const startDate = new Date(this.start)
    const endDate = new Date(this.end)
    const diff = (endDate - startDate) / (24 * 60 * 60 * 1000)
    return Math.floor(diff) + 1
  }

  formatDate(value) {
    const date = new Date(value)
    if (Number.isNaN(date.getTime())) return value

    const day = String(date.getDate()).padStart(2, "0")
    const month = String(date.getMonth() + 1).padStart(2, "0")
    const year = date.getFullYear()
    return `${day}/${month}/${year}`
  }

  updateNavLinks() {
    const links = []
    if (this.hasPrevLinkTarget) links.push(this.prevLinkTarget)
    if (this.hasNextLinkTarget) links.push(this.nextLinkTarget)

    links.forEach((link) => {
      const url = new URL(link.href, window.location.origin)
      if (this.start) {
        url.searchParams.set("start_date", this.start)
      } else {
        url.searchParams.delete("start_date")
      }

      if (this.end) {
        url.searchParams.set("end_date", this.end)
      } else {
        url.searchParams.delete("end_date")
      }

      link.href = url.pathname + url.search
    })
  }
}
