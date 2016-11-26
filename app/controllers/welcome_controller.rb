class WelcomeController < ApplicationController
  def index

    response = HTTParty.get('https://getgo-api.herokuapp.com/agencies/')
    byebug;
    puts response.body
    puts JSON.parse(response.body)

  end
end
