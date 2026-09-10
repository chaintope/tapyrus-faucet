class AllowNullTxidOnTransactions < ActiveRecord::Migration[8.1]
  def change
    change_column_null :transactions, :txid, true
  end
end
