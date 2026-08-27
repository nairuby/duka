# == Schema Information
#
# Table name: payment_transactions
#
#  id                 :uuid             not null, primary key
#  amount             :decimal(10, 2)
#  error_message      :text
#  external_reference :string
#  phone_number       :string
#  processed_at       :datetime
#  raw_response       :jsonb
#  status             :string           not null
#  transaction_type   :string           not null
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  order_id           :uuid             not null
#
# Indexes
#
#  index_payment_transactions_on_external_reference  (external_reference)
#  index_payment_transactions_on_order_id            (order_id)
#  index_payment_transactions_on_phone_number        (phone_number)
#  index_payment_transactions_on_processed_at        (processed_at)
#  index_payment_transactions_on_status              (status)
#  index_payment_transactions_on_transaction_type    (transaction_type)
#
# Foreign Keys
#
#  fk_rails_...  (order_id => orders.id)
#
class PaymentTransaction < ApplicationRecord
  belongs_to :order

  # Constants
  TRANSACTION_TYPES = %w[stk_push callback query].freeze
  STATUSES = %w[initiated pending completed failed timeout success started].freeze

  # Validations
  validates :transaction_type, inclusion: { in: TRANSACTION_TYPES }
  validates :status, inclusion: { in: STATUSES }
  validates :amount, presence: true, numericality: { greater_than: 0 }, if: :stk_push?
  validates :phone_number, presence: true, format: { with: /\A\+254\d{9}\z/, message: "must be a valid Kenyan phone number" }, if: :stk_push?

  # Scopes
  scope :by_type, ->(type) { where(transaction_type: type) }
  scope :by_status, ->(status) { where(status: status) }
  scope :recent, -> { order(created_at: :desc) }
  scope :for_phone, ->(phone) { where(phone_number: phone) }

  # Callbacks
  before_validation :normalize_phone_number
  before_save :set_processed_at, if: :status_changed?

  def successful?
    status == "completed"
  end

  def failed?
    status == "failed"
  end

  def pending?
    status == "pending"
  end

  def stk_push?
    transaction_type == "stk_push"
  end

  def callback?
    transaction_type == "callback"
  end

  private

  def normalize_phone_number
    self.phone_number = PhoneNormalizer.normalize(phone_number, with_plus: true)
  end

  def set_processed_at
    self.processed_at = Time.current if status_changed? && !%w[initiated pending started].include?(status)
  end
end
