// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "controllers"
import "@popperjs/core"
import "bootstrap"

document.addEventListener("turbo:load", () => {
  document.querySelectorAll(".alert").forEach((alert) => {
    window.setTimeout(() => {
      const instance = bootstrap.Alert.getOrCreateInstance(alert)
      instance.close()
    }, 4000)
  })
})
