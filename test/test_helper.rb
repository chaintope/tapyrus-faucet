require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'

class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures :all

  # Add more helper methods to be used by all tests here...
end

# RpcHelperにモンキーパッチしてテストする
class RpcHelper
  def initialize(rpc_user, rpc_password, host, port)
  end

  def rpc(method, *params)
    case method
    when :validateaddress
      {'isvalid' => true}
    when :getbalance
      400
    when :settxfee
      true
    when :sendtoaddress
      SecureRandom.base64(10)
    end
  end
end
