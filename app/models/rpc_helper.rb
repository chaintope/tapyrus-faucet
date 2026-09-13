require 'net/http'
require 'json'

class RpcHelper
  # tapyrusd がエラーを返したときに投げる。ウォレットのロックや同期中など運用者が
  # 対処すべき失敗であり、画面にメッセージを出して終える失敗とは分けて扱う。
  class RpcError < StandardError; end

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
    result_from(method, http.request(request))
  end

  # tapyrusd の応答から result を取り出す。ノードがエラーを返していれば、その内容を
  # 添えて RpcError にする。
  def result_from(method, response)
    body = JSON.parse(response.body)
    raise RpcError, "#{method} failed: #{body['error'].inspect}" if body['error']

    body['result']
  rescue JSON::ParserError
    raise RpcError, "#{method} failed: the node returned a non JSON response (HTTP #{response.code})"
  end
end
