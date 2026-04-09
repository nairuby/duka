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
#  request_payload    :text
#  response_payload   :text
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
require 'rails_helper'

RSpec.describe PaymentTransaction, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
