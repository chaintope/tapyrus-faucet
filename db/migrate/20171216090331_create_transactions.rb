class CreateTransactions < ActiveRecord::Migration[5.1]
  def change
    create_table :transactions do |t|
      t.string :opid,       :null => false
      t.string :address,    :null => false
      t.string :ip_address, :null => false
      t.date   :date,       :null => false
      t.float  :value,      :null => false

      t.timestamps
    end

    add_index :transactions, [:created_at]
    add_index :transactions, [:ip_address, :date], :unique => true
  end
end
