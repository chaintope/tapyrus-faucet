# README

This README would normally document whatever steps are necessary to get the
application up and running.

Things you may want to cover:

# Ruby version
- 2.4.2

# System dependencies
- MySQL
- bundler

# Configuration
## environment variables
- KOTO_RPC_USER
- KOTO_RPC_PASSWORD
- KOTO_FROM_ZADDRESS
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
- KOTO_FAUCET_DATABASE_PASSWORD
- RAILS_SERVE_STATIC_FILES=1

```
$ mysql -uroot -p
mysql> CREATE DATABASE `koto-faucet_production`;
mysql> CREATE USER `koto`@localhost IDENTIFIED BY 'password';
mysql> GRANT ALL PRIVILEGES ON `koto-faucet_production`.* TO `koto`@localhost IDENTIFIED BY 'password';
mysql> FLUSH PRIVILEGES;
mysql> exit
$ RAILS_ENV=production bin/rails db:migrate
$ RAILS_ENV=production bin/rails secret # => SECRET_KEY_BASE
```

### リリースのたびに毎回
```
[ec2-user]
$ sudo su - koto
$ cd koto-faucet

[koto]
$ git pull
$ RAILS_ENV=production bin/rails assets:precompile
$ exit

[ec2-user]
$ sudo su -

[root]
$ cd /srv/www
$ cp -r /home/koto/koto-faucet/public .
$ chown -R nginx public/
$ exit

[ec2-user]
$ sudo su - koto

[koto]
$ source ~/.bashrc
$ ps -ef | grep puma
$ kill -9 pid
$ cd koto-faucet
$ nohup bin/rails server -e production -p 13333 &
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
mysql> SELECT DATE_FORMAT(date, '%Y-%m-%d') AS time, COUNT(*), SUM(value) AS SUM, SUM(value)/COUNT(*) AS AVE FROM `koto-faucet_production`.transactions GROUP BY date;
```