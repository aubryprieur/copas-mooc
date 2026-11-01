import { Controller } from "@hotwired/stimulus"

// Menu principal repliable sur mobile
export default class extends Controller {
  static targets = ["panel", "button"]

  toggle() {
    const open = this.panelTarget.classList.toggle("hidden") === false
    this.panelTarget.classList.toggle("flex", open)
    this.buttonTarget.setAttribute("aria-expanded", String(open))
  }
}
