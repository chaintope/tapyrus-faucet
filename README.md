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
- TAPYRUS_RPC_USER
- TAPYRUS_RPC_PASSWORD
- TAPYRUS_RPC_HOST
- TAPYRUS_RPC_PORT
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
- TAPYRUS_FAUCET_DATABASE_PASSWORD
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

$ cd tapyrus-faucet
$ git pull
$ RAILS_ENV=production bin/rails assets:precompile

$ sudo su -

[root]
$ cd /srv/www
$ cp -r /home/sammy/tapyrus-faucet/public .
$ chown -R nginx public/
$ exit

[sammy]
$ source ~/.profile
$ ps -ef | grep puma
$ kill -9 pid
$ cd tapyrus-faucet
$ nohup bin/rails server -e production -p 3000 &
```

# How to develop on docker images

You can use docker and docker-compose to develop this project. Here is explanation for that.
Before do this process, you need to prepare [tapyrus-core](https://github.com/chaintope/tapyrus-core) full node to 
supply RPC endpoint.

1. Build docker image

```bash
$ cd project/path
$ docker-compose build
``` 

2. create `.env` file
This is a sample of `.env`. You need to specify each environments.

```text
RECAPTCHA_SITE_KEY=xxxx_xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
RECAPTCHA_SECRET_KEY=xxxx_xxxxxxxxxxxxx-xxxxxxxxxxxxxxxxxxxxx
TAPYRUS_RPC_USER=xxxxx
TAPYRUS_RPC_PASSWORD=xxxxx
TAPYRUS_RPC_HOST=xxxxx.xxxxx.xxxx
TAPYRUS_RPC_PORT=xxxxx
```

You can get recapture keys from [here](https://www.google.com/recaptcha/intro/v3.html).

3. Create database and migrate it

```bash
$ docker-compose up
$ docker-compose run web rails db:create
$ docker-compose run web rails db:migrate
```

4. Access `http://localhost:3000` from any browser 

[http://localhost:3000](`http://localhost:3000`)

# 復旧手段
```
[local]
$ ssh -i ~/.ssh/time4vps -p 50417 sammy@yourhost

[server]
$ sudo su - tapyrus
$ tapyrusd -daemon
$ exit

$ cd ~/tapyrus-faucet
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