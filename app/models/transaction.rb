class Transaction < ApplicationRecord
  validates :txid,       presence: true
  validates :address,    presence: true
  validates :ip_address, presence: true, :uniqueness => { :scope => [:date] }
  validates :date,       presence: true
  validates :value,      presence: true, numericality: true
  default_scope -> { order(created_at: :desc) }
  self.per_page = 20

  VALUE = 0.001
  FEE = 0.001

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
    self.value      = VALUE

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

    if current_balance < ( value + FEE )
      errors.add(:value, '申し訳ございません。力尽きましたでございます。')
      raise
    end

    self.txid = RpcHelper.rpc(:sendtoaddress, address, value)
    if txid.blank?
      errors.add(:txid, '申し訳ございません。sendtoaddressに失敗しました。少し時間をあけてから再度お試しください。解決しない場合はお手数おかけいたしまして申し訳ございませんが管理者までご連絡ください。')
      raise
    end
    save!
  end
end
