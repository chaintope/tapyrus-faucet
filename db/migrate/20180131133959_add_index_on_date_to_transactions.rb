class AddIndexOnDateToTransactions < ActiveRecord::Migration[5.1]
  def change
    add_index :transactions, [:date]
  end
end
