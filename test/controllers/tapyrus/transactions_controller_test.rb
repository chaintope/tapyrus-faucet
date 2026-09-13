require 'test_helper'

class Tapyrus::TransactionsControllerTest < ActionDispatch::IntegrationTest
  ADDRESS = '1LxWufmUothBSe78DYESKcoP8ppmPcSHZ6'.freeze
  # ロードバランサはプライベートサブネットにいるため、Rails は信頼できるプロキシとして扱う
  LB_ADDR = '10.0.1.5'.freeze
  CLIENT_IP = '203.0.113.9'.freeze
  BLACKLISTED_IP = TransactionsController::BLACK_LIST.first.freeze

  # ロードバランサは X-Forwarded-For の右端にクライアントの IP を追記する。
  # spoofed はクライアントが自分で付けてきた値である。
  def post_create(address: ADDRESS, client_ip: CLIENT_IP, spoofed: nil, spoofed_client_ip: nil)
    forwarded_for = [spoofed, client_ip].compact.join(', ')
    headers = { 'REMOTE_ADDR' => LB_ADDR, 'HTTP_X_FORWARDED_FOR' => forwarded_for }
    headers['HTTP_CLIENT_IP'] = spoofed_client_ip if spoofed_client_ip
    post tapyrus_transactions_path,
         params: { tapyrus_transaction: { address: address } },
         headers: headers
  end

  test '記録される IP はロードバランサが追記した実クライアントの IP である' do
    post_create(spoofed: '1.2.3.4')

    assert_equal 1, Transaction.count
    assert_equal CLIENT_IP, Transaction.first.ip_address
  end

  test 'X-Forwarded-For を偽装しても1日1回の制限を回避できない' do
    post_create(spoofed: '1.2.3.4')
    assert_equal 1, rpc_stub.count(:sendtoaddress)

    post_create(address: 'anotheraddress', spoofed: '5.6.7.8')

    assert_equal 1, Transaction.count
    assert_equal 1, rpc_stub.count(:sendtoaddress)
    assert_response :success
  end

  test 'X-Forwarded-For を偽装してもブラックリストを回避できない' do
    post_create(client_ip: BLACKLISTED_IP, spoofed: '1.2.3.4')

    assert_equal 0, Transaction.count
    assert_equal 0, rpc_stub.count(:sendtoaddress)
    assert_redirected_to tapyrus_transactions_path
  end

  test 'Client-IP を偽装しても1日1回の制限を回避できない' do
    post_create(spoofed_client_ip: '1.2.3.4')

    assert_equal 1, Transaction.count
    assert_equal CLIENT_IP, Transaction.first.ip_address

    post_create(address: 'another-address', spoofed_client_ip: '5.6.7.8')

    assert_equal 1, Transaction.count
    assert_equal 1, rpc_stub.count(:sendtoaddress)
    assert_response :success
  end

  test 'ブラックリストに載っていない相手は受け取れる' do
    post_create

    assert_equal 1, Transaction.count
    assert_redirected_to tapyrus_transactions_path
  end

  test '想定外の例外は握りつぶさずそのまま外へ出る' do
    rpc_stub.before_sendtoaddress = ->(*) { raise Errno::ECONNREFUSED }

    assert_raises(Errno::ECONNREFUSED) { post_create }

    # 送金の結果が分からないため、確保したレコードは残る
    assert_equal 1, Transaction.count
    assert_nil Transaction.first.txid
  end

  test 'ノードが返したエラーは運用者向けに記録して外へ出す' do
    rpc_stub.before_sendtoaddress = ->(*) { raise RpcHelper::RpcError, 'sendtoaddress failed: wallet locked' }

    log = capture_rails_log do
      assert_raises(RpcHelper::RpcError) { post_create }
    end

    assert_match 'failed to distribute coins', log
    assert_match 'wallet locked', log
  end

  test 'パラメータの欠けた POST は運用者向けのエラーにしない' do
    log = capture_rails_log do
      post tapyrus_transactions_path,
           headers: { 'REMOTE_ADDR' => LB_ADDR, 'HTTP_X_FORWARDED_FOR' => CLIENT_IP }
    end

    assert_response :success
    assert_equal 0, Transaction.count
    refute_match 'failed to distribute coins', log
    assert_match 'coins were not distributed', log
  end

  test '想定外の例外は原因がログに残る' do
    rpc_stub.before_sendtoaddress = ->(*) { raise Errno::ECONNREFUSED }

    log = capture_rails_log do
      assert_raises(Errno::ECONNREFUSED) { post_create }
    end

    assert_match 'failed to distribute coins', log
    assert_match 'Errno::ECONNREFUSED', log
  end

  test '配布できない理由はログに残り、画面はフォームへ戻る' do
    post_create

    log = capture_rails_log { post_create(address: 'another-address') }

    assert_response :success
    assert_match 'coins were not distributed', log
    assert_match 'already got coins', log
  end

  test 'FAUCET_DISABLE_IP_LIMIT が有効なら同じ相手が繰り返し受け取れる' do
    with_env('FAUCET_DISABLE_IP_LIMIT' => 'true') do
      post_create(address: 'address-1')
      post_create(address: 'address-2')
    end

    assert_equal 2, Transaction.count
    assert_equal 2, rpc_stub.count(:sendtoaddress)
  end
end
