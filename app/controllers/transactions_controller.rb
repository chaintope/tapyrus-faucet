class TransactionsController < ApplicationController

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

  # Overrideしてほしいメソッド ↓↓↓
  def klass
    raise
  end

  def index_path
    raise
  end

  def donate_to
    raise
  end

  def parameters_key
    raise
  end

  def footer_medi8_ad_url
    raise
  end

  def title
    raise
  end

  def favicon
    raise
  end
  # Overrideしてほしいメソッド ↑↑↑

  def index
    @klass = klass
    @transactions = @klass.paginate(:page => params[:page])
    @transaction = @klass.new
    # @wallet_address = @klass.wallet_address
    # @donate_to = donate_to
    # @footer_medi8_ad_url = footer_medi8_ad_url
    @title = title
    @favicon = favicon
  end

  def create
    @klass = klass
    @transaction = @klass.new(transaction_params)
    @transaction.ip_address = Rails.env.production? ? ip_address : Time.now.to_s
    if @transaction.address == 'k1D2ZEuiWyfyyrZYuK5w8UjsmkZTyTn2hVo'
      # スパム野郎が攻撃に成功したとおもわせる
      flash[:info] = 'Please check your wallet!'
      redirect_to index_path
      return
    end
    if BLACK_LIST.include?(@transaction.ip_address)
      # スパム野郎が攻撃に成功したとおもわせる
      flash[:info] = 'Please check your wallet!'
      redirect_to index_path
      return
    end

    if !verify_recaptcha(model: @transaction)
      flash[:info] = 'robot!'
      raise
    end

    @transaction.send!
    flash[:info] = 'Please check your wallet!'
    redirect_to index_path
  rescue => e
    @klass = klass
    @transactions = @klass.paginate(:page => params[:page])
    @wallet_address = @klass.wallet_address
    @donate_to = donate_to
    @footer_medi8_ad_url = footer_medi8_ad_url
    @title = title
    @favicon = favicon
    render :index
  end

  private
    def transaction_params
      params.require(parameters_key).permit(:address)
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
end