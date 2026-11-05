require 'test_helper'

class Tapyrus::TransactionsControllerTest < ActionDispatch::IntegrationTest
  ADDRESS = '1LxWufmUothBSe78DYESKcoP8ppmPcSHZ6'.freeze
  # ロードバランサはプライベートサブネットにいるため、Rails は信頼できるプロキシとして扱う
  LB_ADDR = '10.0.1.5'.freeze
  CLIENT_IP = '203.0.113.9'.freeze
  BLACKLISTED_IP = TransactionsController::BLACK_LIST.first.freeze

  # ロードバランサは X-Forwarded-For の右端にクライアントの IP を追記する。
  # spoofed はクライアントが自分で付けてきた値である。
  # client_ip に nil を渡すと、ロードバランサを通らずに X-Forwarded-For が無い状態になる。
  def post_create(address: ADDRESS, client_ip: CLIENT_IP, spoofed: nil, spoofed_client_ip: nil, extra_headers: {})
    forwarded_for = [spoofed, client_ip].compact.join(', ')
    headers = { 'REMOTE_ADDR' => LB_ADDR }
    headers['HTTP_X_FORWARDED_FOR'] = forwarded_for unless forwarded_for.empty?
    headers['HTTP_CLIENT_IP'] = spoofed_client_ip if spoofed_client_ip
    headers.merge!(extra_headers)
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

  [
    'for=1.2.3.4',
    'for="1.2.3.4"',
    'for=1.2.3.4, for=5.6.7.8',
    'for="[2001:db8::1]"'
  ].each do |forwarded|
    test "Forwarded: #{forwarded} を付けても記録される IP は変わらない" do
      post_create(extra_headers: { 'HTTP_FORWARDED' => forwarded })

      assert_equal 1, Transaction.count
      assert_equal CLIENT_IP, Transaction.first.ip_address
    end
  end

  test 'Forwarded を偽装しても1日1回の制限を回避できない' do
    post_create(extra_headers: { 'HTTP_FORWARDED' => 'for=1.2.3.4' })
    post_create(address: 'another-address', extra_headers: { 'HTTP_FORWARDED' => 'for=5.6.7.8' })

    assert_equal 1, Transaction.count
    assert_equal 1, rpc_stub.count(:sendtoaddress)
    assert_response :success
  end

  test 'Forwarded を偽装してもブラックリストを回避できない' do
    post_create(client_ip: BLACKLISTED_IP, extra_headers: { 'HTTP_FORWARDED' => 'for=1.2.3.4' })

    assert_equal 0, Transaction.count
    assert_equal 0, rpc_stub.count(:sendtoaddress)
    assert_redirected_to tapyrus_transactions_path
  end

  test 'X-Forwarded-For が無いときに Forwarded だけを付けても、その値は使われない' do
    post_create(client_ip: nil, extra_headers: { 'HTTP_FORWARDED' => 'for=1.2.3.4' })

    assert_equal 1, Transaction.count
    assert_equal LB_ADDR, Transaction.first.ip_address
  end

  test 'X-Forwarded-Host を偽装してもリダイレクト先の host は変わらない' do
    post_create(extra_headers: { 'HTTP_X_FORWARDED_HOST' => 'evil.example' })

    assert_redirected_to tapyrus_transactions_path
    assert_equal 'www.example.com', URI(response.location).host
  end

  test 'ブラックリストに載っていない相手は受け取れる' do
    post_create

    assert_equal 1, Transaction.count
    assert_redirected_to tapyrus_transactions_path
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
