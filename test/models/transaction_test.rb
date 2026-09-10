require 'test_helper'

class TransactionTest < ActiveSupport::TestCase
  ADDRESS = '1LxWufmUothBSe78DYESKcoP8ppmPcSHZ6'.freeze
  OTHER_ADDRESS = '1MZFsdpZhbLmnMHYAdRwUeqmSMEQZKmsZK'.freeze
  IP = '203.0.113.9'.freeze
  OTHER_IP = '203.0.113.10'.freeze

  def build_transaction(address: ADDRESS, ip_address: IP)
    Tapyrus::Transaction.new(address: address, ip_address: ip_address)
  end

  test '送金に成功すると txid を持つレコードが1件残る' do
    rpc_stub.txid = 'a' * 64
    transaction = build_transaction

    transaction.send!

    assert_equal 1, Transaction.count
    assert_equal 'a' * 64, transaction.reload.txid
    assert_equal ADDRESS, transaction.address
    assert_equal IP, transaction.ip_address
    assert_equal Time.zone.now.to_date, transaction.date
    assert_equal 1, rpc_stub.count(:sendtoaddress)
  end

  test '配布額は残高に配布率を掛けた値である' do
    with_env('DISTRIBUTION_RATE' => '5e-06') do
      rpc_stub.balance = 400.0
      transaction = build_transaction

      transaction.send!

      assert_in_delta 0.002, transaction.value, 1e-9
    end
  end

  test '同じアドレスの当日2回目は拒否され送金されない' do
    build_transaction.send!
    assert_equal 1, rpc_stub.count(:sendtoaddress)

    second = build_transaction(ip_address: OTHER_IP)
    assert_raises(StandardError) { second.send! }

    assert_equal 1, Transaction.count
    assert_equal 1, rpc_stub.count(:sendtoaddress)
    assert_includes second.errors.full_messages.join(' '), 'already got coins'
  end

  test '同じ IP の当日2回目は拒否され送金されない' do
    build_transaction.send!

    second = build_transaction(address: OTHER_ADDRESS)
    assert_raises(StandardError) { second.send! }

    assert_equal 1, Transaction.count
    assert_equal 1, rpc_stub.count(:sendtoaddress)
    assert_includes second.errors.full_messages.join(' '), 'already got coins'
  end

  test '前日に受け取っていても当日は受け取れる' do
    build_transaction.send!
    Transaction.update_all(date: Time.zone.now.to_date - 1)

    build_transaction.send!

    assert_equal 2, Transaction.count
    assert_equal 2, rpc_stub.count(:sendtoaddress)
  end

  test 'アドレスが空なら送金されない' do
    transaction = build_transaction(address: nil)

    assert_raises(StandardError) { transaction.send! }

    assert_equal 0, Transaction.count
    assert_equal 0, rpc_stub.count(:sendtoaddress)
  end

  test 'ノードが不正と判定したアドレスへは送金されない' do
    rpc_stub.valid_address = false
    transaction = build_transaction

    assert_raises(StandardError) { transaction.send! }

    assert_equal 0, Transaction.count
    assert_equal 0, rpc_stub.count(:sendtoaddress)
  end

  test '残高が配布額と手数料に足りなければ送金されない' do
    rpc_stub.balance = 0.0001
    transaction = build_transaction

    assert_raises(StandardError) { transaction.send! }

    assert_equal 0, Transaction.count
    assert_equal 0, rpc_stub.count(:sendtoaddress)
  end

  test '送金が txid を返さなければレコードは残らない' do
    rpc_stub.txid = ''
    transaction = build_transaction

    assert_raises(StandardError) { transaction.send! }

    assert_equal 0, Transaction.count
  end

  test '送金に失敗した相手は同じ日に再試行できる' do
    rpc_stub.txid = ''
    assert_raises(StandardError) { build_transaction.send! }

    rpc_stub.txid = 'b' * 64
    build_transaction.send!

    assert_equal 1, Transaction.count
    assert_equal 'b' * 64, Transaction.first.txid
  end
end

# 並行リクエストの検証はトランザクション外で行う。スレッドごとに別の接続を使うため、
# テストを包むトランザクションの中では互いのレコードが見えない。
class TransactionConcurrencyTest < ActiveSupport::TestCase
  self.use_transactional_tests = false

  ADDRESS = '1LxWufmUothBSe78DYESKcoP8ppmPcSHZ6'.freeze
  IP = '203.0.113.9'.freeze

  setup { Transaction.delete_all }
  teardown { Transaction.delete_all }

  def build_transaction
    Tapyrus::Transaction.new(address: ADDRESS, ip_address: IP)
  end

  test '事前チェックが空振りしてもレコードを確保できるのは1件だけである' do
    build_transaction.send!

    second = build_transaction
    # 並行するリクエストが同時に事前チェックを通過した状態を作る
    def second.already_distributed?
      false
    end

    assert_raises(StandardError) { second.send! }

    assert_equal 1, Transaction.count
    assert_equal 1, rpc_stub.count(:sendtoaddress)
  end

  test '同じ相手から同時に要求しても送金は1回だけである' do
    # 確保してから送金するまでの間を広げ、競合が起きやすい状態にする
    rpc_stub.before_sendtoaddress = ->(*) { sleep 0.2 }

    gate = Queue.new
    threads = 4.times.map do
      Thread.new do
        gate.pop
        ActiveRecord::Base.connection_pool.with_connection do
          begin
            build_transaction.send!
            :ok
          rescue StandardError
            :ng
          end
        end
      end
    end
    4.times { gate << :go }
    results = threads.map(&:value)

    assert_equal 1, results.count(:ok)
    assert_equal 1, Transaction.count
    assert_equal 1, rpc_stub.count(:sendtoaddress)
    assert_not_nil Transaction.first.txid
  end
end
