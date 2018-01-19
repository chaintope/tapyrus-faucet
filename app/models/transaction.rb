class Transaction < ApplicationRecord
  validates :opid,       presence: true
  validates :address,    presence: true
  validates :ip_address, presence: true, :uniqueness => { :scope => [:date] }
  validates :date,       presence: true
  validates :value,      presence: true, numericality: true
  default_scope -> { order(created_at: :desc) }
  self.per_page = 20


  VALUE_ARY      = ([3.9] * 100) + [39]
  VALUE_ARY2     = [0.01, 0.0123, 0.0114114, 0.00114114, 0.029, 0.0029, 0.0039, 0.039, 0.05]
  FROM_ZADDRESS  = ENV['KOTO_FROM_ZADDRESS']
  DONATE_ADDRESS = 'k16MSRriSxNq75Xo3k5Qy4nGnqR6nRhurHJ'

  class << self
    def balance
      RpcHelper.rpc(:getbalance)
    end
  end

  def send!
    current_balance = Transaction.balance

    self.date       = Time.zone.now.beginning_of_day
    self.value      = current_balance > 500 ? VALUE_ARY.sample : VALUE_ARY2.sample

    if self.address.blank?
      errors.add(:address, 'あなた様のアドレスが指定されておりません')
      raise
    end

    unless RpcHelper.rpc(:validateaddress, self.address)['isvalid']
      errors.add(:address, 'アドレスに誤りがございます')
      raise
    end

    if Transaction.find_by(ip_address: self.ip_address, date: self.date)
      errors.add(:date, '本日はご利用済です。明日のご利用を心よりお待ちいたしております。')
      raise
    end

    if current_balance < ( self.value + 0.04 )
      errors.add(:value, '申し訳ございません。力尽きましたでございます。')
      raise
    end

    self.opid = RpcHelper.rpc(:sendtoaddress, self.address, value)
    if self.opid.blank?
      errors.add(:opid, '申し訳ございません。sendtoaddressに失敗しました。少し時間をあけてから再度お試しください。解決しない場合はお手数おかけいたしまして申し訳ございませんが管理者までご連絡ください。')
      raise
    end
    save!
  end
end
