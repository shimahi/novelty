require 'test_helper'

class OrderControllerTest < ActionDispatch::IntegrationTest
  test "should get top" do
    get order_top_url
    assert_response :success
  end

end
