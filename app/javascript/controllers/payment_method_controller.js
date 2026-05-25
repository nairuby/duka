import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [ "phoneInput" ]

  connect() {
    this.togglePhone()
  }

  togglePhone() {
    const selectedMethod = this.element.querySelector('input[type="radio"]:checked')?.value
    if (selectedMethod === 'mpesa') {
      this.phoneInputTarget.classList.remove('hidden')
    } else {
      // Since this controller is on the label, it only sees its own radio button.
      // However, we want to hide it if another method is selected.
      // Actually, if we put the controller on a parent container, it would work better.
    }
  }
}
