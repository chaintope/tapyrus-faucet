class Tapyrus::Transaction < Transaction
  def rpc_helper
    @rpc_helper ||= RpcHelper.new(
                      ENV['TAPYRUS_RPC_USER'],
                      ENV['TAPYRUS_RPC_PASSWORD'],
                      ENV['TAPYRUS_RPC_HOST'],
                      ENV['TAPYRUS_RPC_PORT'])
  end

  def calc_value
    # 残高が400のときに0.0002くらいなる係数
    value = Tapyrus::Transaction.balance
    (value * 5.527638190954774e-07).round(8)
  end
end