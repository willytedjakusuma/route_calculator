FROM ruby:3.2

RUN apt-get update -qq && apt-get install -y build-essential

WORKDIR /route_calculator

COPY Gemfile* ./
RUN bundle install

COPY . .

ENTRYPOINT ["bundle", "exec"]
CMD ["ruby", "main.rb"]