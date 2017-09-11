require 'test_helper'

class SiteLayoutTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:test_user)
  end

  test 'layout links' do
    # not logged in
    get root_path
    assert_select 'a[href=?]', root_path, count: 2
    assert_select 'a[href=?]', help_path
    assert_select 'a[href=?]', about_path
    assert_select 'a[href=?]', contact_path
    assert_select 'a[href=?]', login_path

    # logged in
    log_in_as(@user)
    follow_redirect!
    assert_select 'a[href=?]', root_path, count: 2
    assert_select 'a[href=?]', help_path
    assert_select 'a[href=?]', about_path
    assert_select 'a[href=?]', contact_path
    assert_select 'a[href=?]', users_path
    assert_select 'a[href=?]', user_path(@user)
    assert_select 'a[href=?]', edit_user_path(@user)
    assert_select 'a[href=?]', logout_path
  end
end
