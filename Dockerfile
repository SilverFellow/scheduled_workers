FROM j406660003/ruby-http:2.4.3
WORKDIR /worker
COPY / .
RUN bundle install
CMD rake worker
