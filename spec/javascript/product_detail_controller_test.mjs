// Run with: node --test spec/javascript/product_detail_controller_test.mjs
import assert from "node:assert/strict"
import { readFileSync } from "node:fs"
import { test } from "node:test"
import { runInNewContext } from "node:vm"

// Load the real controller with only the Stimulus base class replaced. Targets
// below represent the DOM elements supplied by Stimulus on the product page.
const source = readFileSync(new URL("../../app/javascript/controllers/product_detail_controller.js", import.meta.url), "utf8")
const ProductDetailController = runInNewContext(
  source.replace('import { Controller } from "@hotwired/stimulus"', "class Controller {}")
    .replace("export default class", "class ProductDetailController") + "\nProductDetailController",
  { window: {}, console: { log() {} } }
)

function controller() {
  const instance = new ProductDetailController()
  instance.connect()
  instance.variants = [
    { id: "red-m", size: "M", color: "Red", stock_quantity: 5 },
    { id: "blue-l", size: "L", color: "Blue", stock_quantity: 0 }
  ]
  instance.stockInfoTarget = { textContent: "", innerHTML: "" }
  instance.addToCartBtnTarget = { disabled: true, value: "Add to Cart" }
  instance.cartHelpTarget = { textContent: "" }
  instance.variantIdFieldTarget = { value: "" }
  instance.hasVariantIdFieldTarget = true
  return instance
}

test("explains which options are still needed before adding to cart", () => {
  const page = controller()
  page.updateVariant()
  assert.equal(page.addToCartBtnTarget.disabled, true)
  assert.equal(page.cartHelpTarget.textContent, "Choose a size and color to add this item to your cart.")

  page.selectedSize = "M"
  page.updateVariant()
  assert.equal(page.cartHelpTarget.textContent, "Choose a color to add this item to your cart.")

  page.selectedSize = null
  page.selectedColor = "Red"
  page.updateVariant()
  assert.equal(page.cartHelpTarget.textContent, "Choose a size to add this item to your cart.")
})

test("enables an in-stock selection and preserves the submit input label", () => {
  const page = controller()
  page.selectedSize = "M"
  page.selectedColor = "Red"
  page.updateVariant()
  assert.equal(page.addToCartBtnTarget.disabled, false)
  assert.equal(page.addToCartBtnTarget.value, "Add to Cart")
  assert.equal(page.variantIdFieldTarget.value, "red-m")
  assert.match(page.cartHelpTarget.textContent, /in stock and ready/)
})

test("explains sold-out selections and recovers when an in-stock option is chosen", () => {
  const page = controller()
  page.selectedSize = "L"
  page.selectedColor = "Blue"
  page.updateVariant()
  assert.equal(page.addToCartBtnTarget.disabled, true)
  assert.match(page.cartHelpTarget.textContent, /out of stock.*choose another option/)

  page.selectedSize = "M"
  page.selectedColor = "Red"
  page.updateVariant()
  assert.equal(page.addToCartBtnTarget.disabled, false)
  assert.match(page.cartHelpTarget.textContent, /in stock and ready/)
})

test("distinguishes unavailable combinations from missing options and clears stale variant IDs", () => {
  const page = controller()
  page.selectedSize = "M"
  page.selectedColor = "Red"
  page.updateVariant()
  page.selectedColor = "Blue"
  page.updateVariant()
  assert.equal(page.addToCartBtnTarget.disabled, true)
  assert.equal(page.variantIdFieldTarget.value, "")
  assert.match(page.cartHelpTarget.textContent, /combination is unavailable/)
})

test("leaves products without variants ready to order", () => {
  const page = new ProductDetailController()
  page.addToCartBtnTarget = { disabled: false }
  page.connect()
  assert.equal(page.addToCartBtnTarget.disabled, false)
})
