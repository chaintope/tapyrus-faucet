class Transaction < ApplicationRecord
  validates :opid,       presence: true
  validates :address,    presence: true
  validates :ip_address, presence: true, :uniqueness => { :scope => [:date] }
  validates :date,       presence: true
  validates :value,      presence: true, numericality: true

  VALUE          = 0.01
  FROM_ZADDRESS  = ENV['KOTO_FROM_ZADDRESS']
  DONATE_ADDRESS = 'k19Jtp5NDJcj4pCQoeTEgksLWp9HW9qKuqJ'

  class << self
    def balance
      RpcHelper.rpc(:z_getbalance, FROM_ZADDRESS)
    end
  end

  def send!
    self.date       = Time.zone.now.beginning_of_day
    self.value      = VALUE

    if self.address.blank?
      errors.add(:address, 'あなた様のアドレスが指定されておりません')
      raise
    end

    if !RpcHelper.rpc(:validateaddress, self.address)['isvalid'] && !RpcHelper.rpc(:z_validateaddress, self.address)['isvalid']
      errors.add(:address, 'アドレスに誤りがございます')
      raise
    end

    if Transaction.find_by(address: self.address, date: self.date)
      errors.add(:date, '本日はご利用済です。明日のご利用を心よりお待ちいたしております。')
      raise
    end

    if RpcHelper.rpc(:z_getbalance, FROM_ZADDRESS) < ( VALUE + 0.04)
      errors.add(:value, '申し訳ございません。力尽きましたでございます。')
      raise
    end

    self.opid = RpcHelper.rpc(:z_sendmany, FROM_ZADDRESS, [ { address: self.address, amount: self.value } ])
    save!
  end
end
