require 'test_helper'

class UsersIndexTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:test_user)
  end

  test 'users list' do
    log_in_as(@user)
    follow_redirect!
    assert_select 'a[href=?]', users_path
    get users_path
    assert_template 'users/index'
    assert_select 'ul.users>li>a[href=?]', user_path(@user), 'test_user'
  end
end
