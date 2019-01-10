FROM ruby:2.6.0-alpine

ENV APP /app
WORKDIR $APP

COPY Gemfile Gemfile.lock $APP/

RUN bundle install

ADD . $APP

EXPOSE 5000

CMD rackup --host 0.0.0.0 -p 5000
