import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["variantSelector", "stockInfo", "stockCount", "addToCartBtn", "selectedSku"]

  connect() {
    this.selectedSize = null
    this.selectedColor = null
    this.variants = this.getVariantsData()
  }

  selectSize(event) {
    // Remove active class from all size buttons
    this.element.querySelectorAll('[data-action*="selectSize"]').forEach(btn => {
      btn.classList.remove('bg-blue-600', 'text-white', 'border-blue-600')
      btn.classList.add('border-gray-300', 'text-gray-700')
    })

    // Add active class to selected button
    event.target.classList.remove('border-gray-300', 'text-gray-700')
    event.target.classList.add('bg-blue-600', 'text-white', 'border-blue-600')

    this.selectedSize = event.target.dataset.size
    this.updateVariantInfo()
  }

  selectColor(event) {
    // Remove active class from all color buttons
    this.element.querySelectorAll('[data-action*="selectColor"]').forEach(btn => {
      btn.classList.remove('bg-blue-600', 'text-white', 'border-blue-600')
      btn.classList.add('border-gray-300', 'text-gray-700')
    })

    // Add active class to selected button
    event.target.classList.remove('border-gray-300', 'text-gray-700')
    event.target.classList.add('bg-blue-600', 'text-white', 'border-blue-600')

    this.selectedColor = event.target.dataset.color
    this.updateVariantInfo()
  }

  updateVariantInfo() {
    const selectedVariant = this.findSelectedVariant()
    
    if (selectedVariant) {
      this.stockCountTarget.textContent = `${selectedVariant.stock_quantity} available`
      this.selectedSkuTarget.textContent = selectedVariant.sku
      
      if (selectedVariant.stock_quantity > 0) {
        this.addToCartBtnTarget.disabled = false
        this.addToCartBtnTarget.textContent = "Add to Cart"
        this.addToCartBtnTarget.classList.remove('bg-gray-400')
        this.addToCartBtnTarget.classList.add('bg-blue-600', 'hover:bg-blue-700')
      } else {
        this.addToCartBtnTarget.disabled = true
        this.addToCartBtnTarget.textContent = "Out of Stock"
        this.addToCartBtnTarget.classList.remove('bg-blue-600', 'hover:bg-blue-700')
        this.addToCartBtnTarget.classList.add('bg-gray-400')
      }
    } else {
      this.stockCountTarget.textContent = "Select variant to see availability"
      this.selectedSkuTarget.textContent = "-"
      this.addToCartBtnTarget.disabled = true
      this.addToCartBtnTarget.textContent = "Select Options"
      this.addToCartBtnTarget.classList.remove('bg-blue-600', 'hover:bg-blue-700')
      this.addToCartBtnTarget.classList.add('bg-gray-400')
    }
  }

  findSelectedVariant() {
    if (!this.selectedSize || !this.selectedColor) return null
    
    return this.variants.find(variant => 
      variant.size === this.selectedSize && variant.color === this.selectedColor
    )
  }

  getVariantsData() {
    // This would typically come from a data attribute or API call
    // For now, we'll return an empty array and populate it via Rails
    const variantsData = this.element.dataset.variants
    return variantsData ? JSON.parse(variantsData) : []
  }
}