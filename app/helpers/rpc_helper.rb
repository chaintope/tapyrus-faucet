require 'net/http'
require 'json'

module RpcHelper
  RPC_USER = ENV['MONACOIN_MAIN_FAUCET_RPC_USER']
  RPC_PASSWORD = ENV['MONACOIN_MAIN_FAUCET_RPC_PASSWORD']
  HOST = Rails.env.production? ? 'localhost' : '192.168.1.12'
  PORT = Rails.env.production? ? 9402 : 19402

  class << self
    def rpc(method, *params)
      http = Net::HTTP.new(HOST, PORT)
      request = Net::HTTP::Post.new('/')
      request.basic_auth(RPC_USER, RPC_PASSWORD)
      request.content_type = 'application/json'
      request.body = { method: method.to_s, params: params, id: 'jsonrpc' }.to_json
      result_json = http.request(request).body
      JSON.parse(result_json)['result']
    end
  end
end