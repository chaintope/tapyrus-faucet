require 'open-uri'
require 'timeout'
require 'json'

class Monacoin::Transaction < Transaction
  DEFAULT_VALUE = 0.0006
  DEFAULT_FEE   = 0.001 # Set the transaction fee per kB. Overwrites the paytxfee parameter.

  def rpc_helper
    @rpc_helper ||= RpcHelper.new(
                      ENV['MONACOIN_MAIN_FAUCET_RPC_USER'],
                      ENV['MONACOIN_MAIN_FAUCET_RPC_PASSWORD'],
                      Rails.env.production? ? 'localhost' : '192.168.1.12',
                      Rails.env.production? ? 9402 : 19402)
  end

  def set_txfee
    value, fee = value_fee

    unless rpc_helper.rpc(:settxfee, fee)
      errors.add(:value, 'error settxfee')
      raise
    end
  end

  def calc_value
    value, fee = value_fee
    value
  end

  private
    def value_fee
      Timeout.timeout(10) do
        j = JSON.parse open('https://firebase.torifuku-kaiou.tokyo/monacoin-main-faucet/faucet.json', &:read)
        [j['value'], j['fee']]
      end
    rescue Timeout::Error
      [DEFAULT_VALUE, DEFAULT_FEE]
    end
end