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
    self.value      = dist_value_ary(current_balance).sample

    if value.nil? || value.zero?
      self.value = 0.0003
    end

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

    if current_balance < ( value + 0.0001 )
      errors.add(:value, '申し訳ございません。力尽きましたでございます。')
      raise
    end

    self.opid = RpcHelper.rpc(:sendtoaddress, address, value)
    if opid.blank?
      errors.add(:opid, '申し訳ございません。sendtoaddressに失敗しました。少し時間をあけてから再度お試しください。解決しない場合はお手数おかけいたしまして申し訳ございませんが管理者までご連絡ください。')
      raise
    end
    save!
  end

  def dist_value_ary(balance)
    case balance
    when 0.00000001...400
      1000.times.map { Random.rand(0.0003).round(7) }.reject { |v| v < 0.0002 }
    when 400...500
      VALUE_ARY2
    else
      VALUE_ARY
    end
  end
end
