class Koto::Transaction < Transaction
  def rpc_helper
    @rpc_helper ||= RpcHelper.new(
                      ENV['KOTO_RPC_FAUCET_USER'],
                      ENV['KOTO_RPC_FAUCET_PASSWORD'],
                      Rails.env.production? ? 'localhost' : '192.168.1.12',
                      8432)
  end

  def calc_value
    # 残高が400のときに0.0002くらいなる係数
    value = Koto::Transaction.balance
    (value * 5.527638190954774e-07).round(8)
  end
end