import { Controller } from "@hotwired/stimulus"

// Recharge la page à intervalle régulier quand elle est visible (signatures qui arrivent en direct).
export default class extends Controller {
  static values = { seconds: { type: Number, default: 15 } }

  connect() {
    this.timer = setInterval(() => {
      if (document.visibilityState === "visible" && !this.busy()) {
        window.Turbo.visit(window.location.href, { action: "replace" })
      }
    }, this.secondsValue * 1000)
  }

  disconnect() { clearInterval(this.timer) }

  // Ne jamais recharger pendant une saisie : champ actif, signature en cours de tracé, fichier choisi.
  busy() {
    if (document.activeElement?.matches("input, textarea, select")) return true
    if (this.element.querySelector("[data-signature-dirty]")) return true
    return Array.from(this.element.querySelectorAll("input[type=file]")).some((i) => i.files.length > 0)
  }
}
