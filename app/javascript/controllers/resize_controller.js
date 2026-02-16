import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["form", "bookingId", "startTime", "endTime"]

  connect() {
    this.resizing = false
    this.edge = null // "top" or "bottom"
    this.bookingCell = null
    this.bookingId = null
    this.originalStart = null
    this.originalEnd = null
    this.currentSlot = null

    this.onMouseMove = this.onMouseMove.bind(this)
    this.onMouseUp = this.onMouseUp.bind(this)
  }

  startTop(event) {
    event.preventDefault()
    event.stopPropagation()
    this.startResize(event, "top")
  }

  startBottom(event) {
    event.preventDefault()
    event.stopPropagation()
    this.startResize(event, "bottom")
  }

  startResize(event, edge) {
    const cell = event.target.closest(".booked-cell")
    if (!cell) return

    this.resizing = true
    this.edge = edge
    this.bookingCell = cell
    this.bookingId = cell.dataset.bookingId
    this.originalStart = cell.dataset.bookingStartTime
    this.originalEnd = cell.dataset.bookingEndTime

    document.body.style.userSelect = "none"
    document.body.style.cursor = edge === "top" ? "n-resize" : "s-resize"
    cell.classList.add("resizing")

    document.addEventListener("mousemove", this.onMouseMove)
    document.addEventListener("mouseup", this.onMouseUp)
  }

  onMouseMove(event) {
    if (!this.resizing) return

    // Find the table row under the cursor
    const el = document.elementFromPoint(event.clientX, event.clientY)
    if (!el) return

    const tr = el.closest("tr")
    if (!tr) return

    // Get the time cell from this row
    const timeCell = tr.querySelector(".time-cell")
    if (!timeCell) return

    // Find a cell in this row with data-hour/data-min (empty-cell or booked-cell start)
    let hour, min
    const dataCell = tr.querySelector("[data-hour][data-min]")
    if (dataCell) {
      hour = parseInt(dataCell.dataset.hour)
      min = parseInt(dataCell.dataset.min)
    } else {
      // Parse from time cell text
      const text = timeCell.textContent.trim()
      const parsed = this.parseTimeText(text)
      if (!parsed) return
      hour = parsed.hour
      min = parsed.min
    }

    const slotKey = `${hour}:${String(min).padStart(2, "0")}`
    if (slotKey === this.currentSlot) return
    this.currentSlot = slotKey

    // Highlight the preview
    this.updatePreview(hour, min)
  }

  parseTimeText(text) {
    // Parse "8:00 AM" format
    const match = text.match(/(\d+):(\d+)\s*(AM|PM)/i)
    if (!match) return null
    let hour = parseInt(match[1])
    const min = parseInt(match[2])
    const ampm = match[3].toUpperCase()
    if (ampm === "PM" && hour < 12) hour += 12
    if (ampm === "AM" && hour === 12) hour = 0
    return { hour, min }
  }

  updatePreview(hour, min) {
    // Remove previous preview classes
    this.element.querySelectorAll(".resize-preview").forEach(el => {
      el.classList.remove("resize-preview")
    })

    // For now just track the target slot - visual preview is optional
    if (this.edge === "top") {
      this.newStart = `${String(hour).padStart(2, "0")}:${String(min).padStart(2, "0")}`
    } else {
      // End time is the slot AFTER the one we're hovering (bottom of that slot = +15min)
      const totalMin = hour * 60 + min + 15
      const endH = Math.floor(totalMin / 60)
      const endM = totalMin % 60
      this.newEnd = `${String(endH).padStart(2, "0")}:${String(endM).padStart(2, "0")}`
    }
  }

  onMouseUp(event) {
    if (!this.resizing) return

    document.removeEventListener("mousemove", this.onMouseMove)
    document.removeEventListener("mouseup", this.onMouseUp)

    document.body.style.userSelect = ""
    document.body.style.cursor = ""
    if (this.bookingCell) this.bookingCell.classList.remove("resizing")

    this.element.querySelectorAll(".resize-preview").forEach(el => {
      el.classList.remove("resize-preview")
    })

    let changed = false

    if (this.edge === "top" && this.newStart && this.newStart !== this.originalStart) {
      this.startTimeTarget.value = this.newStart
      this.endTimeTarget.value = this.originalEnd
      changed = true
    } else if (this.edge === "bottom" && this.newEnd && this.newEnd !== this.originalEnd) {
      this.startTimeTarget.value = this.originalStart
      this.endTimeTarget.value = this.newEnd
      changed = true
    }

    if (changed) {
      this.formTarget.action = this.formTarget.action.replace(/\/\d+$/, `/${this.bookingId}`)
      this.bookingIdTarget.value = this.bookingId

      const scrollY = window.scrollY
      document.addEventListener("turbo:load", () => {
        window.scrollTo(0, scrollY)
      }, { once: true })

      this.formTarget.requestSubmit()
    }

    this.resizing = false
    this.edge = null
    this.bookingCell = null
    this.newStart = null
    this.newEnd = null
    this.currentSlot = null
  }
}
