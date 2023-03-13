module ApplicationHelper
  def version
    rpc_helper.rpc(:getnetworkinfo)&.[]('subversion')
  end

  private

  def rpc_helper
    RpcHelper.new(
      ENV['TAPYRUS_RPC_USER'],
      ENV['TAPYRUS_RPC_PASSWORD'],
      ENV['TAPYRUS_RPC_HOST'],
      ENV['TAPYRUS_RPC_PORT'])
  end
end
