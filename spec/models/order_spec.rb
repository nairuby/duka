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
require 'rails_helper'

RSpec.describe Order, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
