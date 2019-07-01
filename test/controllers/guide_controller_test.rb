require 'test_helper'

class GuideControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get guide_index_url
    assert_response :success
  end

  test "should get flow" do
    get guide_flow_url
    assert_response :success
  end

  test "should get business" do
    get guide_business_url
    assert_response :success
  end

  test "should get care" do
    get guide_care_url
    assert_response :success
  end

end
