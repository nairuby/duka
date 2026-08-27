class AddQuikkFieldsToOrders < ActiveRecord::Migration[8.1]
  def change
    add_column :orders, :quikk_request_id, :string
    add_column :orders, :mpesa_receipt, :string
  end
end
