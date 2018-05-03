class Monacoin::Testnet::Transaction < Transaction
  def rpc_helper
    @rpc_helper ||= RpcHelper.new(
                      ENV['MONACOIN_TESTNET_FAUCET_RPC_USER'],
                      ENV['MONACOIN_TESTNET_FAUCET_RPC_PASSWORD'],
                      Rails.env.production? ? 'localhost' : '192.168.1.12',
                      Rails.env.production? ? 9402 : 19402)
  end

  def value
    10
  end
end