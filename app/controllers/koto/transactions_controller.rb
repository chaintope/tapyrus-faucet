require 'open-uri'
require 'timeout'

class Koto::TransactionsController < TransactionsController
  def klass
    Koto::Transaction
  end

  def index_path
    koto_transactions_path
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
    :koto_transaction
  end

  def footer_medi8_ad_url
    "https://js.medi-8.net/t/286/293/a1286293.js"
  end
end