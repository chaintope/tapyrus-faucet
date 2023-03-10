# Dockerfile for to build tapyrus-faucet web application runnning environment.
FROM ruby:2.7

ENV LANG C.UTF-8
ENV APP=/tapyrus-faucet

RUN apt-get update && \
    apt-get install -y build-essential libpq-dev libmariadb-dev nodejs
RUN mkdir $APP
WORKDIR $APP
COPY . $APP
RUN  bundle update --bundler && \
     bundle install

COPY entrypoint.sh /usr/bin/
RUN chmod +x /usr/bin/entrypoint.sh
ENTRYPOINT ["entrypoint.sh"]
EXPOSE 3000

CMD ["rails", "server", "-b", "0.0.0.0"]
