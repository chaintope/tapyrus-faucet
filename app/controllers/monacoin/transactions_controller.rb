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
end