require 'test_helper'

class UsersControllerTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:test_user)
  end

  test 'should get new' do
    get signup_url
    assert_response :success
  end

  test 'should redirect edit when not logged in' do
    get edit_user_path(@user)
    assert_not_empty flash[:danger]
    assert_redirected_to login_url
  end

  test 'should redirect update when not logged in' do
    patch user_path(@user), params: { user: { name: 'foo', email: 'bar' }}
    assert_not_empty flash[:danger]
    assert_redirected_to login_url
  end
end
