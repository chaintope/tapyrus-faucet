require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'

# tapyrusd への接続をテスト中だけ差し替えるスタブである。呼び出しを記録し、戻り値を
# テストごとに変えられるようにしてある。
class RpcStub
  DEFAULT_BALANCE = 400.0

  attr_accessor :balance, :valid_address, :txid, :before_sendtoaddress

  def initialize
    @mutex = Mutex.new
    @calls = []
    @balance = DEFAULT_BALANCE
    @valid_address = true
    @txid = nil
  end

  def call(method, *params)
    @mutex.synchronize { @calls << [method, *params] }

    case method
    when :validateaddress
      { 'isvalid' => valid_address }
    when :getbalance
      balance
    when :settxfee
      true
    when :sendtoaddress
      before_sendtoaddress&.call(*params)
      txid.nil? ? SecureRandom.hex(16) : txid
    end
  end

  def calls
    @mutex.synchronize { @calls.dup }
  end

  def count(method)
    calls.count { |call| call.first == method }
  end
end

# RpcHelper は tapyrusd へ HTTP で接続する。テストでは接続せず RpcStub へ委譲する。
class RpcHelper
  class << self
    attr_accessor :stub
  end

  def initialize(rpc_user = nil, rpc_password = nil, host = nil, port = nil)
  end

  def rpc(method, *params)
    RpcHelper.stub.call(method, *params)
  end
end

class ActiveSupport::TestCase
  fixtures :all

  setup do
    RpcHelper.stub = RpcStub.new
  end

  def rpc_stub
    RpcHelper.stub
  end

  # 環境変数をテストの間だけ差し替える
  def with_env(values)
    saved = values.keys.to_h { |key| [key, ENV[key]] }
    values.each { |key, value| ENV[key] = value }
    yield
  ensure
    saved.each { |key, value| value.nil? ? ENV.delete(key) : ENV[key] = value }
  end
end
