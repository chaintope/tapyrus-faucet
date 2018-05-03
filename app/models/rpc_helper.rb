require 'net/http'
require 'json'

class RpcHelper
  attr_accessor :rpc_user, :rpc_password, :host, :port

  def initialize(rpc_user, rpc_password, host, port)
    self.rpc_user = rpc_user
    self.rpc_password = rpc_password
    self.host = host
    self.port = port
  end

  def rpc(method, *params)
    http = Net::HTTP.new(host, port)
    request = Net::HTTP::Post.new('/')
    request.basic_auth(rpc_user, rpc_password)
    request.content_type = 'application/json'
    request.body = { method: method.to_s, params: params, id: 'jsonrpc' }.to_json
    result_json = http.request(request).body
    JSON.parse(result_json)['result']
  end
end