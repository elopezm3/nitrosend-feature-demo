class CreateContacts < ActiveRecord::Migration[7.2]
  def change
    create_table :contacts do |t|
      t.string :email
      t.string :first_name
      t.string :last_name
      t.string :source
      t.string :status
      t.datetime :subscribed_at
      t.datetime :unsubscribed_at

      t.timestamps
    end
    add_index :contacts, :email, unique: true
  end
end
