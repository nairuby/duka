import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [ "status" ]
  static values = {
    url: String,
    redirectUrl: String
  }

  connect() {
    this.attempts = 0
    this.maxAttempts = 12 // 60 seconds (every 5 seconds)
    this.poll()
  }

  disconnect() {
    this.stopPolling()
  }

  poll() {
    this.pollingTimer = setInterval(async () => {
      this.attempts++
      
      try {
        const response = await fetch(this.urlValue)
        const data = await response.json()

        if (data.status === 'paid') {
          this.stopPolling()
          window.location.href = this.redirectUrlValue
        } else if (data.status === 'failed') {
          this.stopPolling()
          this.statusTarget.textContent = "Payment failed. Redirecting back..."
          setTimeout(() => {
            window.location.href = '/checkout/payment?alert=Payment failed'
          }, 2000)
        } else if (this.attempts >= this.maxAttempts) {
          this.stopPolling()
          this.statusTarget.textContent = "Payment timed out. Running final check..."
          // Final check
          const finalResponse = await fetch(this.urlValue + "&timeout=true")
          const finalData = await finalResponse.json()
          if (finalData.status === 'paid') {
            window.location.href = this.redirectUrlValue
          } else {
            this.statusTarget.textContent = "Payment timed out. Please try again or use another method."
          }
        }
      } catch (error) {
        console.error("Polling error:", error)
      }
    }, 5000)
  }

  stopPolling() {
    if (this.pollingTimer) {
      clearInterval(this.pollingTimer)
    }
  }
}
