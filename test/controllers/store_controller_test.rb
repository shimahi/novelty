require 'test_helper'

class StoreControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get store_index_url
    assert_response :success
  end

  test "should get privacy" do
    get store_privacy_url
    assert_response :success
  end

  test "should get tos" do
    get store_tos_url
    assert_response :success
  end

  test "should get specific" do
    get store_specific_url
    assert_response :success
  end

end
