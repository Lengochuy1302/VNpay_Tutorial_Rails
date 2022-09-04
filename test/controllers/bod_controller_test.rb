require "test_helper"

class BodControllerTest < ActionDispatch::IntegrationTest
  test "should get new" do
    get bod_new_url
    assert_response :success
  end
end
