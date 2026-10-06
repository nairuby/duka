class CreateContactMessages < ActiveRecord::Migration[8.1]
  def change
    create_table :contact_messages, id: :uuid, default: -> { "gen_random_uuid()" } do |t|
      t.string :name, null: false
      t.string :email, null: false
      t.string :subject
      t.text :message, null: false
      t.string :status, default: "new", null: false

      t.timestamps
    end
  end
end
