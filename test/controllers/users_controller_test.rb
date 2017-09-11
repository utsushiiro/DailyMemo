require 'test_helper'

class UsersControllerTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:test_user)
    @other_user = users(:another_test_user)
  end

  test 'should redirect index when not logged in' do
    get users_path
    assert_redirected_to login_url
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

  test 'should redirect edit when logged in as a wrong user' do
    log_in_as(@other_user)
    get edit_user_path(@user)
    assert_redirected_to root_url
  end

  test 'should redirect update when logged in as a wrong user' do
    log_in_as(@other_user)
    patch user_path(@user), params: { user: { name: 'foo', email: 'bar' }}
    assert_redirected_to root_url
  end
end
