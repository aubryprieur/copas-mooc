import { Controller } from "@hotwired/stimulus"

// Mesure le temps actif sur un module (indicateur 19 Qualiopi : effectivité du suivi à distance).
// Le temps n'est compté que si l'onglet est visible et que l'apprenant a interagi
// (souris, clavier, défilement, lecture vidéo) dans les 2 dernières minutes.
const INTERVAL = 30
const IDLE_LIMIT = 120 * 1000

export default class extends Controller {
  static values = { url: String }

  connect() {
    this.lastInteraction = Date.now()
    this.bump = () => { this.lastInteraction = Date.now() }
    for (const evt of ["mousemove", "keydown", "scroll", "touchstart"]) {
      window.addEventListener(evt, this.bump, { passive: true })
    }
    this.videos = this.element.querySelectorAll("video")
    this.timer = setInterval(() => this.beat(), INTERVAL * 1000)
  }

  disconnect() {
    clearInterval(this.timer)
    for (const evt of ["mousemove", "keydown", "scroll", "touchstart"]) {
      window.removeEventListener(evt, this.bump)
    }
  }

  beat() {
    const videoPlaying = Array.from(this.videos).some((v) => !v.paused && !v.ended)
    const active = document.visibilityState === "visible" &&
      (videoPlaying || Date.now() - this.lastInteraction < IDLE_LIMIT)
    if (!active) return

    const token = document.querySelector("meta[name='csrf-token']")?.content
    fetch(this.urlValue, {
      method: "POST",
      headers: { "X-CSRF-Token": token, "Content-Type": "application/x-www-form-urlencoded" },
      body: `seconds=${INTERVAL}`,
      credentials: "same-origin",
      keepalive: true
    }).catch(() => {})
  }
}
