class AddIndexToTransactions < ActiveRecord::Migration[5.1]
  def change
    add_index :transactions, [:address, :date]
  end
end
