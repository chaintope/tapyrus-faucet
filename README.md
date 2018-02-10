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
- MONACOIN_MAIN_FAUCET_DATABASE_PASSWORD
- RAILS_SERVE_STATIC_FILES=1

```
$ mysql -uroot -p
# mysql> CREATE DATABASE `monacoin-main-faucet_production`;
mysql> CREATE USER `mona-main-faucet`@localhost IDENTIFIED BY 'password';
mysql> GRANT ALL PRIVILEGES ON `monacoin-main-faucet_production`.* TO `mona-main-faucet`@localhost IDENTIFIED BY 'password';
mysql> FLUSH PRIVILEGES;
mysql> exit
$ RAILS_ENV=production bin/rails db:create
$ RAILS_ENV=production bin/rails db:migrate
$ RAILS_ENV=production bin/rails secret # => SECRET_KEY_BASE
```

### リリースのたびに毎回
```
[ec2-user]
$ sudo su - monacoin
$ cd monacoin-main-faucet

[monacoin]
$ git pull
$ RAILS_ENV=production bin/rails assets:precompile
$ exit

[ec2-user]
$ sudo su -

[root]
$ cd /srv/www
$ cp -r /home/monacoin/monacoin-main-faucet/public .
$ chown -R nginx public/
$ exit

[ec2-user]
$ sudo su - monacoin

[monacoin]
$ source ~/.bashrc
$ ps -ef | grep puma
$ kill -9 pid
$ cd monacoin-main-faucet
$ nohup bin/rails server -e production -p 23333 &
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
mysql> SELECT DATE_FORMAT(date, '%Y-%m-%d') AS time, COUNT(*), SUM(value) AS SUM, SUM(value)/COUNT(*) AS AVE FROM `monacoin-main-faucet_production`.transactions GROUP BY date;
```