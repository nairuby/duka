import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["preview", "backdrop"]

  connect() {
    // Only log in development
    if (window.location.hostname === 'localhost') {
      console.log("Cart preview controller connected")
    }
    
    // Make open function globally accessible
    window.openCart = () => this.open()
    
    // Preserve open state after Turbo Stream updates
    this.preserveState()
  }
  
  disconnect() {
    // Clean up global function
    delete window.openCart
  }

  preserveState() {
    // Check if cart was open before update (backdrop visible = cart was open)
    if (this.hasBackdropTarget && !this.backdropTarget.classList.contains('hidden')) {
      // Keep it open without triggering reflow
      requestAnimationFrame(() => {
        if (this.hasPreviewTarget) {
          this.previewTarget.classList.remove('translate-x-full')
        }
        document.body.style.overflow = 'hidden'
      })
    }
  }

  open() {
    if (this.hasPreviewTarget && this.hasBackdropTarget) {
      // Use requestAnimationFrame for smoother animation
      requestAnimationFrame(() => {
        this.previewTarget.classList.remove('translate-x-full')
        this.backdropTarget.classList.remove('hidden')
        document.body.style.overflow = 'hidden'
      })
    }
  }

  close() {
    if (this.hasPreviewTarget && this.hasBackdropTarget) {
      requestAnimationFrame(() => {
        this.previewTarget.classList.add('translate-x-full')
        this.backdropTarget.classList.add('hidden')
        document.body.style.overflow = ''
      })
    }
  }

  toggle() {
    if (this.hasPreviewTarget) {
      if (this.previewTarget.classList.contains('translate-x-full')) {
        this.open()
      } else {
        this.close()
      }
    }
  }
}
