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
        const response = await fetch(this.urlValue, {
          headers: { "Accept": "application/json" } // explicitly request json
        })

        if (!response.ok) {
          console.error("Polling request failed:", response.status)
          return // don't stop polling, just skip this attempt
        }

        const data = await response.json()

        if (data.status === 'paid') {
          this.stopPolling()
          window.location.href = this.redirectUrlValue
        } else if (data.status === 'failed') {
          this.stopPolling()
          this.statusTarget.textContent = "Payment failed. Redirecting back..."
          setTimeout(() => {
            window.location.href = '/checkout/payment'
          }, 2000)
        } else if (this.attempts >= this.maxAttempts) {
          this.stopPolling()
          this.statusTarget.textContent = "Payment timed out. Running final check..."
          
          // Commented out because search API is not configured yet
          // // Final check
          // const finalResponse = await fetch(this.urlValue + "?timeout=true")
          // const finalData = await finalResponse.json()
          // if (finalData.status === 'paid') {
          //   window.location.href = this.redirectUrlValue
          // } else {
          //   this.statusTarget.textContent = "Payment timed out. Please try again or use another method."
          // }
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
