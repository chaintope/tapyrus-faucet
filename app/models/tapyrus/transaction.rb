class Tapyrus::Transaction < Transaction
  # 残高が400のときに0.0002くらいなる係数
  DEFAULT_RATE = 5.527638190954774e-07

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
    (value * rate).round(8)
  end

  private

  def rate
    (ENV['DISTRIBUTION_RATE'] && ENV['DISTRIBUTION_RATE'].to_f) || DEFAULT_RATE
  end
end