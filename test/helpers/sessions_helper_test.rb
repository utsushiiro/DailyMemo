require 'test_helper'

class SessionsHelperTest < ActionView::TestCase

  def setup
    @user = users(:test_user)
    remember @user
  end

  test 'current_user returns right user when user_id is stored only in cookies' do
    assert_equal @user, current_user
    assert is_logged_in?
  end

  test 'current_user returns nil when remember digest is wrong' do
    @user.update_attribute(:remember_digest, User.digest(User.create_remember_token))
    assert_nil current_user
  end
end