require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module TapyrusFaucet
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 8.0

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.
    config.time_zone = 'Tokyo' #アプリケーションのタイムゾーン
    config.active_record.default_timezone = :local #データベースのタイムゾーン

    # 前段のロードバランサは X-Forwarded-For だけを使い、Client-IP は付けない。利用者が
    # Client-IP を付けてきても X-Forwarded-For の右端が実クライアントの IP なので、両者の
    # 食い違いを偽装として扱う必要が無い。例外にすると、Rails::Rack::Logger が remote_ip を
    # 読む時点で 500 になり、コントローラでは何も返せなくなる。
    config.action_dispatch.ip_spoofing_check = false
  end
end
