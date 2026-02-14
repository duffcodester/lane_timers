import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["form", "bookingId", "lane", "startTime"]

  dragstart(event) {
    const cell = event.target.closest(".booked-cell")
    if (!cell) return

    const bookingId = cell.dataset.bookingId
    event.dataTransfer.setData("text/plain", bookingId)
    event.dataTransfer.effectAllowed = "move"
    cell.classList.add("dragging")
  }

  dragover(event) {
    event.preventDefault()
    event.dataTransfer.dropEffect = "move"
  }

  dragenter(event) {
    const cell = event.target.closest(".empty-cell")
    if (cell) cell.classList.add("drag-over")
  }

  dragleave(event) {
    const cell = event.target.closest(".empty-cell")
    if (cell) cell.classList.remove("drag-over")
  }

  drop(event) {
    event.preventDefault()
    const cell = event.target.closest(".empty-cell")
    if (!cell) return

    cell.classList.remove("drag-over")

    const bookingId = event.dataTransfer.getData("text/plain")
    if (!bookingId) return

    const lane = cell.dataset.lane
    const hour = cell.dataset.hour.padStart(2, "0")
    const min = cell.dataset.min.padStart(2, "0")

    this.formTarget.action = this.formTarget.action.replace(/\/\d+$/, `/${bookingId}`)
    this.bookingIdTarget.value = bookingId
    this.laneTarget.value = lane
    this.startTimeTarget.value = `${hour}:${min}`
    this.formTarget.requestSubmit()
  }

  dragend(event) {
    const cell = event.target.closest(".booked-cell")
    if (cell) cell.classList.remove("dragging")

    this.element.querySelectorAll(".drag-over").forEach(el => el.classList.remove("drag-over"))
  }
}
