source 'https://rubygems.org'

# config/application.rb で読み込むフレームワークだけを依存にする。使わないフレームワークの gem を
# インストールしないためである。更新は次のようにまとめて行う。
#   bundle update railties activemodel activerecord actionpack actionview --conservative
gem 'railties', '~> 8.1.0'
gem 'activemodel', '~> 8.1.0'
gem 'activerecord', '~> 8.1.0'
gem 'actionpack', '~> 8.1.0'
gem 'actionview', '~> 8.1.0'
# Use mysql as the database for Active Record
gem 'mysql2', '~> 0.5.0'
# Use Puma as the app server
gem 'puma', '>= 5.0'
# Use Terser as compressor for JavaScript assets
gem 'terser'

# Turbo (replaces Turbolinks)
gem 'turbo-rails'

# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder'

# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

gem 'will_paginate'
gem 'bootstrap-sass', '3.4.1'
gem 'bootstrap-will_paginate', '1.0.0'

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', require: false

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

group :development, :test do
  # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  gem 'debug', platforms: %i[mri windows], require: 'debug/prelude'
  # Adds support for Capybara system testing and selenium driver
  gem 'capybara'
  gem 'selenium-webdriver'
end

group :development do
  # Access an interactive console on exception pages or by calling 'console' anywhere in the code.
  gem 'web-console'
  gem 'listen'
  gem 'bullet'
  gem 'brakeman', require: false
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:windows, :jruby]

gem 'recaptcha', require: 'recaptcha/rails'

# For sprockets (asset pipeline)
gem 'sprockets-rails'
gem 'sassc-rails'