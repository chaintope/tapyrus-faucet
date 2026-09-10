class Transaction < ApplicationRecord
  # 配布できない理由が利用者の側にあるもの。画面にメッセージを出して終える。
  # ノードの停止など運用者が知るべき失敗は、この例外にせずそのまま外へ出す。
  class DistributionError < StandardError; end

  validates :type,       presence: true
  validates :address,    presence: true, :uniqueness => { :scope => [:type, :date] }
  validates :ip_address, presence: true, :uniqueness => { :scope => [:type, :date] }
  validates :date,       presence: true
  validates :value,      presence: true, numericality: true
  default_scope -> { order(created_at: :desc) }
  self.per_page = 20

  class << self
    def wallet_address
      ENV['RETURN_ADDRESS']
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

  def calc_value
    raise 'Not implemented'
  end

  def send!
    self.date       = Time.zone.now.beginning_of_day

    if address.blank?
      errors.add(:address, 'Input your address')
      raise DistributionError
    end

    unless rpc_helper.rpc(:validateaddress, address)['isvalid']
      errors.add(:address, 'the address is something wrong.')
      raise DistributionError
    end

    set_txfee

    self.value = calc_value

    claim!

    begin
      # 0.000226はsettxfeeに0.001を指定していたときにUTXOが1件のときの手数料になることが多い数字　これ以上ないとどうしようもない。
      unless rpc_helper.rpc(:getbalance) >= (value + 0.000226)
        errors.add(:value, 'The balance of this faucet is disappeared. OMG!')
        raise DistributionError
      end

      self.txid = rpc_helper.rpc(:sendtoaddress, address, value)
      if txid.blank?
        errors.add(:txid, 'The balance of this faucet is disappeared. OMG!')
        raise DistributionError
      end
      save!
    rescue StandardError
      # 送金前に失敗した場合だけ確保を解く。送金後に失敗したときレコードを消すと、
      # 出ていったコインの記録が残らず、同じ相手がその日にもう一度受け取れてしまう。
      destroy if txid.blank?
      raise
    end
  end

  private

  # 当日分のレコードを先に確保する。確保できたリクエストだけが送金へ進むため、
  # 並行するリクエストが同じ相手へ二重に送金することは無い。競合の裁定は
  # (type, address, date) と (type, ip_address, date) のユニークインデックスが行う。
  def claim!
    raise DistributionError if already_distributed?

    begin
      save!
    rescue ActiveRecord::RecordInvalid, ActiveRecord::RecordNotUnique
      errors.clear
      unless already_distributed?
        errors.add(:base, 'You already got coins from here today. Try tomorrow please.')
      end
      raise DistributionError
    end
  end

  # 当日すでに配布済みなら、理由をerrorsに積んでtrueを返す
  def already_distributed?
    if Transaction.find_by(type: type, ip_address: ip_address, date: date)
      errors.add(:ip_address, 'You already got coins from here today. Try tomorrow please.')
      return true
    end

    if Transaction.find_by(type: type, address: address, date: date)
      errors.add(:address, 'You already got coins from here today. Try tomorrow please.')
      return true
    end

    false
  end
end
