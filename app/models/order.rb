# == Schema Information
#
# Table name: orders
#
#  id                   :uuid             not null, primary key
#  billing_address      :jsonb
#  currency             :string           default("KES")
#  email                :string
#  mpesa_receipt        :string
#  notes                :text
#  order_number         :string
#  payment_completed_at :datetime
#  payment_initiated_at :datetime
#  payment_method       :string
#  payment_reference    :string
#  payment_status       :string           default("pending")
#  payment_timeout_at   :datetime
#  phone                :string
#  session_token        :string
#  shipping_address     :jsonb
#  shipping_city        :string
#  shipping_cost        :decimal(10, 2)   default(0.0)
#  shipping_country     :string           default("Kenya")
#  shipping_name        :string
#  shipping_postal_code :string
#  status               :string           default("cart"), not null
#  subtotal             :decimal(10, 2)
#  total                :decimal(10, 2)   default(0.0), not null
#  user_email           :string
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  quikk_request_id     :string
#  user_id              :uuid
#
# Indexes
#
#  index_orders_on_email           (email)
#  index_orders_on_order_number    (order_number) UNIQUE
#  index_orders_on_payment_status  (payment_status)
#  index_orders_on_session_token   (session_token)
#  index_orders_on_status          (status)
#  index_orders_on_user_id         (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
class Order < ApplicationRecord
  belongs_to :user, optional: true
  has_many :order_items, dependent: :destroy
  has_many :payment_transactions, dependent: :destroy

  # Status constants
  STATUSES = %w[pending confirmed processing shipped delivered cancelled].freeze
  PAYMENT_STATUSES = %w[pending paid failed refunded started timed_out].freeze
  PAYMENT_METHODS = %w[card cash_on_delivery mpesa].freeze

  # Validations
  validates :order_number, presence: true, uniqueness: true
  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :phone, presence: true
  validates :status, inclusion: { in: STATUSES }
  validates :payment_status, inclusion: { in: PAYMENT_STATUSES }
  validates :payment_method, inclusion: { in: PAYMENT_METHODS }, allow_nil: true
  validates :subtotal, :total, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :shipping_cost, numericality: { greater_than_or_equal_to: 0 }
  validates :shipping_name, :shipping_address, :shipping_city, :shipping_country, presence: true
  validate :payment_method_not_bank_transfer, on: :update

  # Callbacks
  before_validation :generate_order_number, on: :create
  before_save :calculate_total

  # Scopes
  scope :recent, -> { order(created_at: :desc) }
  scope :by_status, ->(status) { where(status: status) }
  scope :pending_payment, -> { where(payment_status: "pending") }
  scope :paid, -> { where(payment_status: "paid") }

  def self.create_from_cart(cart, user, checkout_params)
    transaction do
      target_currency = cart.currency || Current.currency || "KES"

      order = new(
        user: user,
        email: checkout_params[:email],
        phone: checkout_params[:phone],
        shipping_name: checkout_params[:shipping_name],
        shipping_address: checkout_params[:shipping_address],
        shipping_city: checkout_params[:shipping_city],
        shipping_postal_code: checkout_params[:shipping_postal_code],
        shipping_country: checkout_params[:shipping_country] || (Current.country_code == "KE" ? "Kenya" : "Kenya"), # Defaulting to Kenya as requested
        notes: checkout_params[:notes],
        currency: target_currency,
        status: "pending",
        payment_status: "pending"
      )

      # Create order items from cart
      cart.items.each do |cart_item|
        # Convert product price to target currency
        price_in_target_currency = CurrencyConverter.convert(cart_item.product.price, "KES", target_currency)
        subtotal_in_target_currency = CurrencyConverter.convert(cart_item.subtotal, "KES", target_currency)

        order.order_items.build(
          product: cart_item.product,
          variant: cart_item.variant,
          quantity: cart_item.quantity,
          price: price_in_target_currency,
          subtotal: subtotal_in_target_currency,
          product_name: cart_item.product.name,
          variant_details: cart_item.variant ? "#{cart_item.variant.size} / #{cart_item.variant.color}" : nil
        )
      end

      # Convert total to target currency
      order.subtotal = CurrencyConverter.convert(cart.total, "KES", target_currency)

      # Shipping calculation (if strict 0.0, conversion is trivial, but good practice to handle)
      shipping_cost_value = calculate_shipping(order)
      # If shipping calculation ever returns non-zero in specific currency, we might need conversion here too.
      # For now, assuming calculate_shipping returns 0.0 or a value in base currency (if we change it later).
      # Since it's 0.0, we just assign it.
      order.shipping_cost = shipping_cost_value

      order.save!

      order
    end
  end

  def self.calculate_shipping(order)
    # Simple shipping calculation - can be enhanced later
    if order.shipping_country == "Kenya"
      0.0 # Free shipping for now
      # if order.shipping_city&.downcase == "nairobi"
      #   200.0 # KES 200 for Nairobi
      # else
      #   500.0 # KES 500 for other Kenyan cities
      # end
    else
      0.0 # Free shipping for international too for now
      # 1500.0 # KES 1500 for international
    end
  end

  def mark_as_paid!(payment_ref = nil)
    update!(
      payment_status: "paid",
      payment_reference: payment_ref,
      status: "confirmed"
    )
  end

  def mark_as_failed!
    update!(payment_status: "failed")
  end

  def can_be_cancelled?
    %w[pending confirmed].include?(status) && payment_status != "paid"
  end

  def cancel!
    return false unless can_be_cancelled?

    update!(status: "cancelled")
  end

  def can_retry_payment?
    payment_status == "failed"
  end

  private

  def payment_method_not_bank_transfer
    if payment_method == "bank_transfer"
      errors.add(:payment_method, "Bank transfers are no longer supported")
    end
  end

  def generate_order_number
    self.order_number ||= "ORD-#{Time.current.strftime('%Y%m%d')}-#{SecureRandom.hex(4).upcase}"
  end

  def calculate_total
    self.total = (subtotal || 0) + (shipping_cost || 0)
  end
end
