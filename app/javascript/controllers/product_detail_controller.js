import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["sizeButton", "colorButton", "stockInfo", "addToCartBtn", "variantIdField", "quantityInput", "cartForm"]
  
  connect() {
    this.selectedSize = null
    this.selectedColor = null
    this.variants = window.productVariants || []
    console.log("Product detail controller connected", this.variants)
  }

  selectSize(event) {
    // Remove active class from all size buttons
    this.sizeButtonTargets.forEach(btn => {
      btn.classList.remove('border-red-600', 'text-red-600', 'bg-red-50')
      btn.classList.add('border-gray-300', 'text-gray-700')
    })
    
    // Add active class to clicked button
    event.currentTarget.classList.remove('border-gray-300', 'text-gray-700')
    event.currentTarget.classList.add('border-red-600', 'text-red-600', 'bg-red-50')
    
    this.selectedSize = event.currentTarget.dataset.size
    this.updateVariant()
  }

  selectColor(event) {
    // Remove active class from all color buttons
    this.colorButtonTargets.forEach(btn => {
      btn.classList.remove('border-red-600', 'text-red-600', 'bg-red-50')
      btn.classList.add('border-gray-300', 'text-gray-700')
    })
    
    // Add active class to clicked button
    event.currentTarget.classList.remove('border-gray-300', 'text-gray-700')
    event.currentTarget.classList.add('border-red-600', 'text-red-600', 'bg-red-50')
    
    this.selectedColor = event.currentTarget.dataset.color
    this.updateVariant()
  }

  updateVariant() {
    // Find matching variant
    const variant = this.variants.find(v => 
      v.size === this.selectedSize && v.color === this.selectedColor
    )

    if (variant) {
      // Update stock info
      if (variant.stock_quantity > 0) {
        this.stockInfoTarget.innerHTML = `<span class="text-green-600 font-bold">${variant.stock_quantity} in stock</span>`
        this.addToCartBtnTarget.disabled = false
        this.addToCartBtnTarget.textContent = "Add to Cart"
      } else {
        this.stockInfoTarget.innerHTML = `<span class="text-red-600 font-bold">Out of stock</span>`
        this.addToCartBtnTarget.disabled = true
        this.addToCartBtnTarget.textContent = "Out of Stock"
      }
      
      // Set variant ID in hidden field
      if (this.hasVariantIdFieldTarget) {
        this.variantIdFieldTarget.value = variant.id
      }
    } else if (this.selectedSize || this.selectedColor) {
      this.stockInfoTarget.textContent = "Select all options to see availability"
      this.addToCartBtnTarget.disabled = true
      this.addToCartBtnTarget.textContent = "Select All Options"
    }
  }

  increaseQuantity(event) {
    event.preventDefault()
    const input = this.quantityInputTarget
    input.value = parseInt(input.value) + 1
  }

  decreaseQuantity(event) {
    event.preventDefault()
    const input = this.quantityInputTarget
    if (parseInt(input.value) > 1) {
      input.value = parseInt(input.value) - 1
    }
  }
}
