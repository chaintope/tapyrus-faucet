require 'open-uri'
require 'timeout'

class Monacoin::Testnet::TransactionsController < TransactionsController
  def klass
    Monacoin::Testnet::Transaction
  end

  def index_path
    monacoin_testnet_transactions_path
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
    :monacoin_testnet_transaction
  end

  def footer_medi8_ad_url
    "https://js.medi-8.net/t/289/073/a1289073.js"
  end

  def title
    'Monacoin testnet4 Faucet'
  end

  def favicon
    'monacoin-favicon.ico'
  end
end