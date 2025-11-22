import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    console.log("Cart preview controller connected")
  }

  open() {
    const preview = document.getElementById('cart_preview')
    const backdrop = document.getElementById('cart_backdrop')
    
    if (preview && backdrop) {
      preview.classList.remove('translate-x-full')
      backdrop.classList.remove('hidden')
      document.body.style.overflow = 'hidden'
    }
  }

  close() {
    const preview = document.getElementById('cart_preview')
    const backdrop = document.getElementById('cart_backdrop')
    
    if (preview && backdrop) {
      preview.classList.add('translate-x-full')
      backdrop.classList.add('hidden')
      document.body.style.overflow = ''
    }
  }

  toggle() {
    const preview = document.getElementById('cart_preview')
    if (preview.classList.contains('translate-x-full')) {
      this.open()
    } else {
      this.close()
    }
  }
}
