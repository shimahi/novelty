require 'test_helper'

class DesignControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get design_index_url
    assert_response :success
  end

  test "should get ai" do
    get design_ai_url
    assert_response :success
  end

  test "should get psd" do
    get design_psd_url
    assert_response :success
  end

  test "should get image" do
    get design_image_url
    assert_response :success
  end

end
