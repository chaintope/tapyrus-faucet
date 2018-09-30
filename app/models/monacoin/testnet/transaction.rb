class Monacoin::Testnet::Transaction < Transaction
  def rpc_helper
    @rpc_helper ||= RpcHelper.new(
                      ENV['MONACOIN_TESTNET_FAUCET_RPC_USER'],
                      ENV['MONACOIN_TESTNET_FAUCET_RPC_PASSWORD'],
                      Rails.env.production? ? 'localhost' : '192.168.1.12',
                      19402)
  end

  def calc_value
    value = Monacoin::Testnet::Transaction.balance
    if value > 10
      5
    else
      (value / 1000.0).round(2)
    end
  end
end