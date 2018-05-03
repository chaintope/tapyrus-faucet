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
end