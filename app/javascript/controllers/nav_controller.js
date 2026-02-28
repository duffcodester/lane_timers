import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["button"]

  toggle() {
    if (this.element.hasAttribute("data-nav-open")) {
      this.close()
    } else {
      this.element.setAttribute("data-nav-open", "")
      this.buttonTarget.textContent = "\u2715"
    }
  }

  close() {
    this.element.removeAttribute("data-nav-open")
    this.buttonTarget.textContent = "\u2630"
  }

  closeOnKeydown(event) {
    if (event.key === "Escape") {
      this.close()
    }
  }
}
