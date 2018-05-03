require 'open-uri'
require 'timeout'

class Monacoin::TransactionsController < TransactionsController
  def klass
    Monacoin::Transaction
  end

  def index_path
    monacoin_transactions_path
  end

  def donate_to
    Timeout.timeout(3) do
      open('https://firebase.torifuku-kaiou.tokyo/monacoin-address') do |f|
        f.read.split("\n").first
      end
    end
  rescue Timeout::Error
    'MLvtg6u9EF32zqpVKXdWv5vcyNbeYrWuVT'
  end

  def parameters_key
    :monacoin_transaction
  end

  def footer_medi8_ad_url
    "https://js.medi-8.net/t/287/241/a1287241.js"
  end

  def title
    'Monacoin Faucet'
  end

  def favicon
    'monacoin-favicon.ico'
  end
end