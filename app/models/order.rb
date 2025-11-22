# == Schema Information
#
# Table name: orders
#
#  id                    :uuid             not null, primary key
#  billing_address       :text
#  currency              :string           default("KES")
#  email                 :string
#  notes                 :text
#  order_number          :string
#  payment_method        :string
#  payment_reference     :string
#  payment_status        :string           default("pending")
#  phone                 :string
#  session_token         :string
#  shipping_address      :text
#  shipping_city         :string
#  shipping_cost         :decimal(10, 2)   default(0.0)
#  shipping_country      :string           default("Kenya")
#  shipping_name         :string
#  shipping_postal_code  :string
#  status                :string
#  subtotal              :decimal(10, 2)
#  total                 :decimal(, )
#  user_email            :string
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  user_id               :uuid
#
# Indexes
#
#  index_orders_on_email          (email)
#  index_orders_on_order_number   (order_number) UNIQUE
#  index_orders_on_payment_status (payment_status)
#  index_orders_on_status         (status)
#  index_orders_on_user_id        (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
class Order < ApplicationRecord
  belongs_to :user, optional: true
  has_many :order_items, dependent: :destroy

  # Status constants
  STATUSES = %w[pending confirmed processing shipped delivered cancelled].freeze
  PAYMENT_STATUSES = %w[pending paid failed refunded].freeze
  PAYMENT_METHODS = %w[mpesa card bank_transfer cash_on_delivery].freeze

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
      order = new(
        user: user,
        email: checkout_params[:email],
        phone: checkout_params[:phone],
        shipping_name: checkout_params[:shipping_name],
        shipping_address: checkout_params[:shipping_address],
        shipping_city: checkout_params[:shipping_city],
        shipping_postal_code: checkout_params[:shipping_postal_code],
        shipping_country: checkout_params[:shipping_country] || "Kenya",
        notes: checkout_params[:notes],
        currency: cart.currency || "KES",
        status: "pending",
        payment_status: "pending"
      )

      # Create order items from cart
      cart.items.each do |cart_item|
        order.order_items.build(
          product: cart_item.product,
          variant: cart_item.variant,
          quantity: cart_item.quantity,
          price: cart_item.product.price,
          subtotal: cart_item.subtotal,
          product_name: cart_item.product.name,
          variant_details: cart_item.variant ? "#{cart_item.variant.size} / #{cart_item.variant.color}" : nil
        )
      end

      order.subtotal = cart.total
      order.shipping_cost = calculate_shipping(order)
      order.save!

      order
    end
  end

  def self.calculate_shipping(order)
    # Simple shipping calculation - can be enhanced later
    if order.shipping_country == "Kenya"
      if order.shipping_city&.downcase == "nairobi"
        200.0 # KES 200 for Nairobi
      else
        500.0 # KES 500 for other Kenyan cities
      end
    else
      1500.0 # KES 1500 for international
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

  private

  def generate_order_number
    self.order_number ||= "ORD-#{Time.current.strftime('%Y%m%d')}-#{SecureRandom.hex(4).upcase}"
  end

  def calculate_total
    self.total = (subtotal || 0) + (shipping_cost || 0)
  end
end
