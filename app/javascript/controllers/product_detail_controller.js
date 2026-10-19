import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["sizeButton", "colorButton", "stockInfo", "addToCartBtn", "variantIdField", "quantityInput", "cartForm", "productImage", "cartHelp"]

  connect() {
    this.selectedSize = null
    this.selectedColor = null
    this.variants = window.productVariants || []
    this.fallbackImageUrl = window.productImageUrl || null
    console.log("Product detail controller connected", this.variants)
    if (this.variants.length > 0) this.updateVariant()
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
    if (!this.selectedSize || !this.selectedColor) {
      const missingOptions = [!this.selectedSize && "size", !this.selectedColor && "color"].filter(Boolean).join(" and ")
      this.stockInfoTarget.textContent = "Select options to see availability"
      this.setCartAvailability(false, `Choose a ${missingOptions} to add this item to your cart.`)
      return
    }

    // Find matching variant
    const variant = this.variants.find(v => 
      v.size === this.selectedSize && v.color === this.selectedColor
    )

    if (variant) {
      // Update stock info
      if (variant.stock_quantity > 0) {
        this.stockInfoTarget.innerHTML = `<span class="text-green-600 font-bold">${variant.stock_quantity} in stock</span>`
        this.setCartAvailability(true, "Your selection is in stock and ready to add to your cart.")
      } else {
        this.stockInfoTarget.innerHTML = `<span class="text-red-600 font-bold">Out of stock</span>`
        this.setCartAvailability(false, "This selection is out of stock. Please choose another option.")
      }
      
      // Set variant ID in hidden field
      if (this.hasVariantIdFieldTarget) {
        this.variantIdFieldTarget.value = variant.id
      }

      // Swap the main image to the variant's own photo, falling back to the
      // product's image when the variant has none set.
      if (this.hasProductImageTarget && this.productImageTarget.tagName === "IMG") {
        const newSrc = variant.image_url || this.fallbackImageUrl
        if (newSrc) {
          this.productImageTarget.src = newSrc
        }
      }
    } else {
      this.stockInfoTarget.textContent = "This combination is unavailable"
      this.setCartAvailability(false, "This size and color combination is unavailable. Please choose another option.")
    }
  }

  setCartAvailability(available, message) {
    this.addToCartBtnTarget.disabled = !available
    this.cartHelpTarget.textContent = message
    if (!available) this.variantIdFieldTarget.value = ""
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
