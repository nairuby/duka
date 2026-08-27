import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    console.log("Cart form controller connected")
  }

  async submit(event) {
    event.preventDefault()
    
    const form = event.target
    const formData = new FormData(form)
    
    try {
      const response = await fetch(form.action, {
        method: form.method,
        body: formData,
        headers: {
          'X-CSRF-Token': document.querySelector('[name="csrf-token"]').content,
          'Accept': 'application/json'
        }
      })
      
      const data = await response.json()
      
      if (data.success) {
        // Show success message
        this.showNotification('Item added to cart!')
        
        // Reload page to update cart content and then open sidebar
        window.location.href = window.location.href + '#cart-open'
        window.location.reload()
      }
    } catch (error) {
      console.error('Error adding to cart:', error)
      alert('Failed to add item to cart. Please try again.')
    }
  }
  
  showNotification(message) {
    // Create a simple notification
    const notification = document.createElement('div')
    notification.className = 'fixed top-4 right-4 bg-green-600 text-white px-6 py-3 rounded-xl shadow-lg z-50 animate-fade-in-up'
    notification.innerHTML = `
      <div class="flex items-center space-x-2">
        <i class="fas fa-check-circle"></i>
        <span>${message}</span>
      </div>
    `
    document.body.appendChild(notification)
    
    setTimeout(() => {
      notification.remove()
    }, 3000)
  }
}
