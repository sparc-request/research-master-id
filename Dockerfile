# Use an official Ruby runtime as a parent image
FROM ruby:2.7.5

# Install Node.js and Yarn, along with other dependencies
RUN apt-get update -qq && apt-get install -y curl gnupg wget build-essential libc6-dev && \
    curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - && \
    echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list && \
    apt-get update -qq && apt-get install -y nodejs yarn

# Install FreeTDS
RUN wget http://www.freetds.org/files/stable/freetds-1.1.24.tar.gz -O /tmp/freetds.tar.gz && \
    tar -xzvf /tmp/freetds.tar.gz -C /tmp && \
    cd /tmp/freetds-1.1.24 && \
    ./configure --prefix=/usr/local --with-tdsver=7.3 && \
    make && make install && \
    rm -rf /tmp/freetds*

# Install the default MySQL client
RUN apt-get install -y default-mysql-client

# Set the working directory in the container
WORKDIR /app

# Copy the Gemfile and Gemfile.lock
COPY Gemfile* ./

# Install the necessary gems
RUN bundle install

# Copy the rest of the application code
COPY . .

# Precompile assets
RUN RAILS_ENV=development bundle exec rake assets:precompile

# Expose port 3002 to the outside world
EXPOSE 3002

# Start the Rails server
CMD ["rails", "server", "-b", "0.0.0.0"]
