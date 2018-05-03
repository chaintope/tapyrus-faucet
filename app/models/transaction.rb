class Transaction < ApplicationRecord
  validates :txid,       presence: true
  validates :type,       presence: true
  validates :address,    presence: true, :uniqueness => { :scope => [:type, :date] }
  validates :ip_address, presence: true, :uniqueness => { :scope => [:type, :date] }
  validates :date,       presence: true
  validates :value,      presence: true, numericality: true
  default_scope -> { order(created_at: :desc) }
  self.per_page = 20

  class << self
    def wallet_address
      # Transactionを生で使うことはない
      # 必ずTransaction::Xxx がnewされている
      new.rpc_helper.rpc(:getaddressesbyaccount, '').first
    end

    def balance
      new.rpc_helper.rpc(:getbalance)
    end
  end

  def rpc_helper
    raise 'Not implemented'
  end

  def set_txfee
    # ここは空にしてTransaction::Monacoinだけ処理が実装されている
  end

  def value
    raise 'Not implemented'
  end

  def send!
    self.date       = Time.zone.now.beginning_of_day

    if address.blank?
      errors.add(:address, 'あなた様のアドレスが指定されておりません')
      raise
    end

    unless rpc_helper.rpc(:validateaddress, address)['isvalid']
      errors.add(:address, 'アドレスに誤りがございます')
      raise
    end

    # typeとip_addressとdate
    if Transaction.find_by(type: type, ip_address: ip_address, date: date)
      errors.add(:ip_address, '本日はご利用済です。明日のご利用を心よりお待ちいたしております。')
      raise
    end

    # typeとaddressとdate
    if Transaction.find_by(type: type, address: address, date: date)
      errors.add(:address, '本日はご利用済です。明日のご利用を心よりお待ちいたしております。')
      raise
    end

    set_txfee

    self.value = value

    # 0.000226はsettxfeeに0.001を指定していたときにUTXOが1件のときの手数料になることが多い数字　これ以上ないとどうしようもない。
    unless rpc_helper.rpc(:getbalance) >= (value + 0.000226)
      errors.add(:value, '申し訳ございません。力尽きましたでございまする。')
      raise
    end

    self.txid = rpc_helper.rpc(:sendtoaddress, address, value)
    if txid.blank?
      errors.add(:txid, '申し訳ございません。送金できませんでした。手数料が不足しているようです。力尽きたでございまする。')
      raise
    end
    save!
  end
end
