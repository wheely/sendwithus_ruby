FROM ruby:2.2

ENV CI 1

RUN mkdir -p /app && mkdir -p /app/lib/send_with_us
WORKDIR /app

ADD ./Gemfile ./
ADD ./send_with_us.gemspec ./
ADD ./lib/send_with_us/version.rb ./lib/send_with_us/

RUN bundle install -j$(nproc) --system

ADD ./ /app/
