class Koto::TransactionsController < ApplicationController
  def index
    @transactions = Transaction.paginate(:page => params[:page])
    @transaction = Transaction.new
  end

  def create
    @transaction = Transaction.new(transaction_params)
    @transaction.ip_address = Rails.env.production? ? ip_address : Time.now.to_s
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
end