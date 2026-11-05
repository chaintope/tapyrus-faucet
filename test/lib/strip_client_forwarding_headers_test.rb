require 'test_helper'

class StripClientForwardingHeadersTest < ActiveSupport::TestCase
  def call_with(headers)
    received = nil
    app = ->(env) { received = env; [200, {}, []] }
    StripClientForwardingHeaders.new(app).call(Rack::MockRequest.env_for('/', headers))
    received
  end

  test '利用者が付けた転送ヘッダを削除する' do
    env = call_with(StripClientForwardingHeaders::HEADERS.to_h { |key| [key, 'spoofed'] })

    StripClientForwardingHeaders::HEADERS.each { |key| assert_nil env[key], key }
  end

  test 'ロードバランサが付けるヘッダは残す' do
    env = call_with(
      'HTTP_X_FORWARDED_FOR' => '203.0.113.9',
      'HTTP_X_FORWARDED_PROTO' => 'https',
      'HTTP_X_FORWARDED_PORT' => '443'
    )

    assert_equal '203.0.113.9', env['HTTP_X_FORWARDED_FOR']
    assert_equal 'https', env['HTTP_X_FORWARDED_PROTO']
    assert_equal '443', env['HTTP_X_FORWARDED_PORT']
  end

  test 'アプリのミドルウェアの先頭に置かれている' do
    assert_equal StripClientForwardingHeaders, Rails.application.middleware.first.klass
  end
end
