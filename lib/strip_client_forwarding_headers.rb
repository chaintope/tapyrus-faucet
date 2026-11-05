# 前段のロードバランサ（AWS ALB）が付ける転送ヘッダは X-Forwarded-For・X-Forwarded-Proto・
# X-Forwarded-Port だけで、それ以外は利用者が付けた値がそのまま届く。Rack と Rails はこれらを読んで
# request.remote_ip・request.host・request.scheme を決めるため、Rails が読む前に削除する。
# ロードバランサより前に Forwarded などを付けるプロキシを置く場合は、削除するヘッダを見直す。
class StripClientForwardingHeaders
  HEADERS = %w[
    HTTP_FORWARDED
    HTTP_X_FORWARDED_HOST
    HTTP_X_FORWARDED_SERVER
    HTTP_X_FORWARDED_SSL
    HTTP_X_FORWARDED_SCHEME
    HTTP_CLIENT_IP
  ].freeze

  def initialize(app)
    @app = app
  end

  def call(env)
    HEADERS.each { |key| env.delete(key) }
    @app.call(env)
  end
end
