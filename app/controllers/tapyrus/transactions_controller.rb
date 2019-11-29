require 'open-uri'
require 'timeout'

class Tapyrus::TransactionsController < TransactionsController
  def klass
    Tapyrus::Transaction
  end

  def index_path
    tapyrus_transactions_path
  end

  def donate_to
    raise
  end

  def parameters_key
    :tapyrus_transaction
  end

  def footer_medi8_ad_url
    raise
  end

  def title
    'Tapyrus Faucet'
  end

  def favicon
    'tapyrus-logo-white.png'
  end
end