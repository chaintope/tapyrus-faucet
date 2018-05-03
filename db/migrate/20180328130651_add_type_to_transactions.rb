class AddTypeToTransactions < ActiveRecord::Migration[5.1]
  def change
    add_column   :transactions, :type, :string
    add_index    :transactions, :type

    remove_index :transactions, name: :index_transactions_on_address_and_date
    remove_index :transactions, name: :index_transactions_on_ip_address_and_date

    add_index    :transactions, [:type, :ip_address, :address, :date], unique: true
  end
end
