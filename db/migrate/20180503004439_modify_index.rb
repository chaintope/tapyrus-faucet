class ModifyIndex < ActiveRecord::Migration[5.1]
  def change
    remove_index :transactions, name: :index_transactions_on_type_and_ip_address_and_address_and_date

    add_index    :transactions, [:type, :ip_address, :date], unique: true
    add_index    :transactions, [:type, :address, :date], unique: true
  end
end
