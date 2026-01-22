import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["track", "status"];
  static values = { month: Number, url: String };

  connect() {
    this.load();
  }

  disconnect() {
    if (this.interval) window.clearInterval(this.interval);
  }

  async load() {
    this.setStatus("Carregando destinos...");
    const url = `${this.urlValue}?month=${this.monthValue}`;

    try {
      const response = await fetch(url, {
        headers: { Accept: "application/json" },
      });
      const data = await response.json();
      this.render(data.items || []);
    } catch (error) {
      this.setStatus("Nao foi possivel carregar destinos.");
    }
  }

  advance() {
    if (!this.hasTrackTarget) return;

    const track = this.trackTarget;
    const card = track.querySelector(".dashboard-card--carousel");
    if (!card) return;

    const gap = parseFloat(getComputedStyle(track).gap || "0");
    const cardWidth = card.getBoundingClientRect().width + gap;
    const maxScroll = track.scrollWidth - track.clientWidth;

    if (track.scrollLeft + cardWidth >= maxScroll) {
      track.scrollTo({ left: 0, behavior: "smooth" });
    } else {
      track.scrollBy({ left: cardWidth, behavior: "smooth" });
    }
  }

  render(items) {
    this.trackTarget.innerHTML = "";

    if (!items.length) {
      this.setStatus("Nenhum destino encontrado.");
      return;
    }

    items.forEach((item) => {
      const card = document.createElement("article");
      card.className = "dashboard-card dashboard-card--carousel";

      const image = document.createElement("div");
      image.className = "dashboard-card__image";
      if (item.image_url) {
        image.style.backgroundImage = `url('${item.image_url}')`;
      } else {
        image.classList.add("dashboard-card__image--placeholder");
      }

      const content = document.createElement("div");
      content.className = "dashboard-card__content";

      if (item.description) {
        const text = document.createElement("p");
        text.className = "dashboard-card__text";
        text.textContent = item.description;
        content.appendChild(text);
      }

      card.appendChild(image);
      card.appendChild(content);
      this.trackTarget.appendChild(card);
    });

    this.setStatus("");
    this.startAutoScroll();
  }

  startAutoScroll() {
    if (this.interval) window.clearInterval(this.interval);
    this.interval = window.setInterval(() => this.advance(), 15000);
  }

  setStatus(message) {
    if (!this.hasStatusTarget) return;
    this.statusTarget.textContent = message;
  }
}
