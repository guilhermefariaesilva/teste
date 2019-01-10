# frozen_string_literal: true

require File.expand_path('test_helper.rb', __dir__)

class IncrementTest < MiniTest::Test
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  def test_increment
    get '/inc'
    previous = last_response.body.to_i

    get '/inc'
    assert last_response.ok?
    assert_equal (previous + 1).to_s, last_response.body
  end
end
