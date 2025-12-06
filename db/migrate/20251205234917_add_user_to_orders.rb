class AddUserToOrders < ActiveRecord::Migration[8.1]
  def change
    add_reference :orders, :user, null: true, foreign_key: true, type: :uuid
  end
end
