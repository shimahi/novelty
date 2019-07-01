require 'test_helper'

class ItemControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get item_index_url
    assert_response :success
  end

  test "should get type" do
    get item_type_url
    assert_response :success
  end

  test "should get price" do
    get item_price_url
    assert_response :success
  end

end
