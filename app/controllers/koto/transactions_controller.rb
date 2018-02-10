require 'open-uri'
require 'timeout'
class Koto::TransactionsController < ApplicationController

  BLACK_LIST = %w(
    123.27.226.137
    5.8.45.111
    5.8.45.86
    5.8.45.70
    5.8.45.109
    5.8.45.101
    5.8.45.18
    5.8.45.76
    5.8.45.125
    5.8.45.100
    5.8.45.85
    5.8.45.13
    5.8.45.14
    5.8.45.104
    5.8.45.91
    5.8.45.12
    5.8.45.43
    5.8.45.127
    5.8.45.84
    5.8.45.81
    5.101.218.221
    5.8.46.191
    5.101.218.165
    5.8.46.181
    5.101.218.228
    5.8.46.231
    5.101.218.178
    5.8.46.186
    5.8.46.230
    5.101.218.148
    5.8.46.250
    5.101.218.245
    5.8.46.248
    5.101.218.234
    5.8.46.135
    5.101.218.143
    5.8.46.235
    5.101.218.238
    5.8.46.237
    5.101.218.179
    5.8.46.217
    5.101.218.190
    5.8.46.209
  )

  def index
    @transactions = Transaction.paginate(:page => params[:page])
    @transaction = Transaction.new
    @askmona_url = askmona_url
  end

  def create
    @transaction = Transaction.new(transaction_params)
    @transaction.ip_address = Rails.env.production? ? ip_address : Time.now.to_s
    if @transaction.address == 'k1D2ZEuiWyfyyrZYuK5w8UjsmkZTyTn2hVo'
      # スパム野郎が攻撃に成功したとおもわせる
      flash[:info] = 'Please check your wallet!'
      redirect_to koto_transactions_path
      return
    end
    if BLACK_LIST.include?(@transaction.ip_address)
      # スパム野郎が攻撃に成功したとおもわせる
      flash[:info] = 'Please check your wallet!'
      redirect_to koto_transactions_path
      return
    end

    if !verify_recaptcha(model: @transaction)
      flash[:info] = 'robot!'
      raise
    end

    @transaction.send!
    flash[:info] = 'Please check your wallet!'
    redirect_to koto_transactions_path
  rescue => e
    @transactions = Transaction.paginate(:page => params[:page])
    render :index
  end

  private
    def transaction_params
      params.require(:transaction).permit(:address)
    end

    def ip_address
      remoteaddr = 'unknown'
      if request.env['HTTP_X_FORWARDED_FOR']
        remoteaddr = request.env['HTTP_X_FORWARDED_FOR'].split(",").first
      else
        remoteaddr = request.env['REMOTE_ADDR'] if request.env['REMOTE_ADDR']
      end

      remoteaddr
    end

    def askmona_url
      Timeout.timeout(3) do
        open('https://firebase.torifuku-kaiou.tokyo/koto_askmona_url.txt', &:read)
      end
    rescue Timeout::Error
      'https://askmona.org/9527'
    end
end