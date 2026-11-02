import { Controller } from "@hotwired/stimulus"

// Zone de signature au doigt ou à la souris ; la signature est envoyée en PNG (data URL).
export default class extends Controller {
  static targets = ["canvas", "input", "error"]

  connect() {
    this.ctx = this.canvasTarget.getContext("2d")
    this.resize()
    this.drawn = 0
    this.canvasTarget.addEventListener("pointerdown", this.start)
    this.canvasTarget.addEventListener("pointermove", this.move)
    window.addEventListener("pointerup", this.end)
  }

  disconnect() {
    window.removeEventListener("pointerup", this.end)
  }

  resize() {
    const ratio = window.devicePixelRatio || 1
    const rect = this.canvasTarget.getBoundingClientRect()
    this.canvasTarget.width = rect.width * ratio
    this.canvasTarget.height = rect.height * ratio
    this.ctx.scale(ratio, ratio)
    this.ctx.lineWidth = 2.2
    this.ctx.lineCap = "round"
    this.ctx.lineJoin = "round"
    this.ctx.strokeStyle = "#1B2430"
  }

  point(e) {
    const rect = this.canvasTarget.getBoundingClientRect()
    return [e.clientX - rect.left, e.clientY - rect.top]
  }

  start = (e) => {
    e.preventDefault()
    this.canvasTarget.setPointerCapture(e.pointerId)
    this.drawing = true
    const [x, y] = this.point(e)
    this.ctx.beginPath()
    this.ctx.moveTo(x, y)
  }

  move = (e) => {
    if (!this.drawing) return
    const [x, y] = this.point(e)
    this.ctx.lineTo(x, y)
    this.ctx.stroke()
    this.drawn += 1
    this.element.setAttribute("data-signature-dirty", "")
  }

  end = () => { this.drawing = false }

  clear() {
    this.ctx.clearRect(0, 0, this.canvasTarget.width, this.canvasTarget.height)
    this.drawn = 0
    this.inputTarget.value = ""
    this.element.removeAttribute("data-signature-dirty")
  }

  submit(e) {
    if (this.drawn < 8) {
      e.preventDefault()
      if (this.hasErrorTarget) this.errorTarget.hidden = false
      return
    }
    this.inputTarget.value = this.canvasTarget.toDataURL("image/png")
  }
}
