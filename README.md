# README

This README would normally document whatever steps are necessary to get the
application up and running.

Things you may want to cover:

# Ruby version
- 2.5.0

# System dependencies
- MySQL
- bundler

# Configuration
## environment variables
- MONACOIN_MAIN_FAUCET_RPC_USER
- MONACOIN_MAIN_FAUCET_RPC_PASSWORD
- MONACOIN_TESTNET_FAUCET_RPC_USER
- MONACOIN_TESTNET_FAUCET_RPC_PASSWORD
- KOTO_RPC_FAUCET_USER
- KOTO_RPC_FAUCET_PASSWORD
- RAKUTEN_AFFILIATEID
- RECAPTCHA_SITE_KEY
- RECAPTCHA_SECRET_KEY
- MYSQL_ROOT_PASSWORD (for development/test)
- SECRET_KEY_BASE (for production)
```
$ bin/rails secret
```

# Database creation
## development/test
```
$ bin/rails db:create
$ bin/rails db:migrate
```

## production
- TORIFUKU_FAUCET_DATABASE_PASSWORD
- RAILS_SERVE_STATIC_FILES=1

```
$ mysql -uroot -p
# mysql> CREATE DATABASE `torifuku_faucet_production`;
mysql> CREATE USER `torifuku_faucet`@localhost IDENTIFIED BY 'password';
mysql> GRANT ALL PRIVILEGES ON `torifuku_faucet_production`.* TO `torifuku_faucet`@localhost IDENTIFIED BY 'password';
mysql> FLUSH PRIVILEGES;
mysql> exit
$ RAILS_ENV=production bin/rails db:create
$ RAILS_ENV=production bin/rails db:migrate
$ RAILS_ENV=production bin/rails secret # => SECRET_KEY_BASE
```

### リリースのたびに毎回
```
[sammy]
$ sudo apt-get update
$ sudo apt-get upgrade

$ cd torifuku_faucet
$ git pull
$ RAILS_ENV=production bin/rails assets:precompile

$ sudo su -

[root]
$ cd /srv/www
$ cp -r /home/sammy/torifuku_faucet/public .
$ chown -R nginx public/
$ exit

[sammy]
$ source ~/.profile
$ ps -ef | grep puma
$ kill -9 pid
$ cd torifuku_faucet
$ nohup bin/rails server -e production -p 3000 &
```



# Database initialization

# How to run the test suite

```
$ bin/rails test
```

# Services (job queues, cache servers, search engines, etc.)

# Deployment instructions

# いずれ書き足しておきたいこと
- nginxの設定
- sslのこと

# 日別集計

```
mysql> SELECT DATE_FORMAT(date, '%Y-%m-%d') AS time, COUNT(*), SUM(value) AS SUM, SUM(value)/COUNT(*) AS AVE FROM `torifuku_faucet_production`.transactions GROUP BY date;
```