require 'test_helper'

module ManybotsInstagram
  class InstagramControllerTest < ActionController::TestCase
    test "should get index" do
      get :index
      assert_response :success
    end
  
  end
end
