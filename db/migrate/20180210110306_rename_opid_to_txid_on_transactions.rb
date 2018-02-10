class RenameOpidToTxidOnTransactions < ActiveRecord::Migration[5.1]
  def change
    rename_column :transactions, :opid, :txid
  end
end
