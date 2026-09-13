require 'test_helper'

class RpcHelperTest < ActiveSupport::TestCase
  # Net::HTTP の応答の代わりに使う
  Response = Struct.new(:code, :body)

  def helper
    RpcHelper.new('rpcuser', 'rpcpassword', 'localhost', 12381)
  end

  test 'ノードが result を返せばその値を返す' do
    response = Response.new('200', { 'result' => 'a' * 64, 'error' => nil }.to_json)

    assert_equal 'a' * 64, helper.result_from(:sendtoaddress, response)
  end

  test 'ノードがエラーを返したら内容を添えて RpcError にする' do
    body = { 'result' => nil,
             'error' => { 'code' => -13, 'message' => 'Please enter the wallet passphrase' } }
    response = Response.new('500', body.to_json)

    error = assert_raises(RpcHelper::RpcError) { helper.result_from(:sendtoaddress, response) }

    assert_match 'sendtoaddress', error.message
    assert_match 'Please enter the wallet passphrase', error.message
  end

  test 'JSON ではない応答も RpcError にする' do
    response = Response.new('401', '<html>401 Unauthorized</html>')

    error = assert_raises(RpcHelper::RpcError) { helper.result_from(:getbalance, response) }

    assert_match 'getbalance', error.message
    assert_match 'HTTP 401', error.message
  end
end
