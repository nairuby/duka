import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    itemId: String,
    quantity: Number
  }
  
  static targets = ["quantityDisplay"]

  connect() {
    this.isUpdating = false
    this.pendingUpdate = null
  }

  disconnect() {
    if (this.pendingUpdate) {
      clearTimeout(this.pendingUpdate)
    }
  }

  decrease(event) {
    event.preventDefault()
    if (this.isUpdating) return
    
    const newQuantity = this.quantityValue - 1
    if (newQuantity < 1) {
      this.remove(event)
      return
    }
    
    this.updateQuantityOptimistic(newQuantity)
  }

  increase(event) {
    event.preventDefault()
    if (this.isUpdating) return
    
    const newQuantity = this.quantityValue + 1
    this.updateQuantityOptimistic(newQuantity)
  }

  updateQuantityOptimistic(newQuantity) {
    // Update UI immediately (optimistic update)
    if (this.hasQuantityDisplayTarget) {
      this.quantityDisplayTarget.textContent = newQuantity
    }
    this.quantityValue = newQuantity
    
    // Debounce the actual server request
    if (this.pendingUpdate) {
      clearTimeout(this.pendingUpdate)
    }
    
    this.pendingUpdate = setTimeout(() => {
      this.updateQuantityOnServer(newQuantity)
    }, 300) // Wait 300ms before sending request
  }

  async remove(event) {
    event.preventDefault()
    if (this.isUpdating) return
    
    this.isUpdating = true
    
    // Optimistic UI - fade out the item
    this.element.style.opacity = '0.5'
    this.element.style.pointerEvents = 'none'
    
    try {
      const response = await fetch(`/cart/remove_item/${this.itemIdValue}`, {
        method: 'DELETE',
        headers: {
          'X-CSRF-Token': document.querySelector('[name="csrf-token"]').content,
          'Accept': 'text/vnd.turbo-stream.html'
        }
      })
      
      if (response.ok) {
        const html = await response.text()
        Turbo.renderStreamMessage(html)
      } else {
        // Revert optimistic update on error
        this.element.style.opacity = '1'
        this.element.style.pointerEvents = 'auto'
      }
    } catch (error) {
      console.error('Error removing item:', error)
      this.element.style.opacity = '1'
      this.element.style.pointerEvents = 'auto'
    } finally {
      this.isUpdating = false
    }
  }

  async updateQuantityOnServer(newQuantity) {
    if (this.isUpdating) return
    
    this.isUpdating = true
    
    try {
      const formData = new FormData()
      formData.append('quantity', newQuantity)
      
      const response = await fetch(`/cart/update_quantity/${this.itemIdValue}`, {
        method: 'PATCH',
        headers: {
          'X-CSRF-Token': document.querySelector('[name="csrf-token"]').content,
          'Accept': 'text/vnd.turbo-stream.html'
        },
        body: formData
      })
      
      const html = await response.text()
      Turbo.renderStreamMessage(html)
      
      if (!response.ok) {
        console.log('Stock limit reached or error occurred')
      }
    } catch (error) {
      console.error('Error updating quantity:', error)
      // Revert to previous quantity on error
      if (this.hasQuantityDisplayTarget) {
        this.quantityDisplayTarget.textContent = this.quantityValue
      }
    } finally {
      this.isUpdating = false
    }
  }
}
