require 'open-uri'
require 'timeout'
require 'json'

class Transaction < ApplicationRecord
  validates :txid,       presence: true
  validates :address,    presence: true
  validates :ip_address, presence: true, :uniqueness => { :scope => [:date] }
  validates :date,       presence: true
  validates :value,      presence: true, numericality: true
  default_scope -> { order(created_at: :desc) }
  self.per_page = 20

  DEFAULT_VALUE = 0.0006
  DEFAULT_FEE   = 0.001 # Set the transaction fee per kB. Overwrites the paytxfee parameter.

  class << self
    def balance
      RpcHelper.rpc(:getbalance)
    end

    def monacoin_address
      RpcHelper.rpc(:getaddressesbyaccount, '').first
    end
  end

  def send!
    current_balance = Transaction.balance

    self.date       = Time.zone.now.beginning_of_day

    if address.blank?
      errors.add(:address, 'あなた様のアドレスが指定されておりません')
      raise
    end

    unless RpcHelper.rpc(:validateaddress, address)['isvalid']
      errors.add(:address, 'アドレスに誤りがございます')
      raise
    end

    if Transaction.find_by(ip_address: ip_address, date: date)
      errors.add(:date, '本日はご利用済です。明日のご利用を心よりお待ちいたしております。')
      raise
    end

    if address != 'MPg3hUaCLfXXDQdf7nYZMesovc9tcoFzKk' && Transaction.find_by(address: address, date: date)
      errors.add(:address, '本日はご利用済です。明日のご利用を心よりお待ちいたしております。')
      raise
    end

    self.value, fee = value_fee

    unless RpcHelper.rpc(:settxfee, fee)
      errors.add(:value, 'error settxfee')
      raise
    end

    # 0.000226はsettxfeeに0.001を指定していたときにUTXOが1件のときの手数料になることが多い数字　これ以上ないとどうしようもない。
    unless current_balance >= (value + 0.000226)
      errors.add(:value, '申し訳ございません。力尽きましたでございまする。')
      raise
    end

    self.txid = RpcHelper.rpc(:sendtoaddress, address, value)
    if txid.blank?
      errors.add(:txid, '申し訳ございません。送金できませんでした。手数料が不足しているようです。力尽きたでございまする。')
      raise
    end
    save!
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
