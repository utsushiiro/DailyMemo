require 'test_helper'

class UsersEditTest < ActionDispatch::IntegrationTest
 def setup
   @user = users(:test_user)
 end

  test 'unsuccessful edit' do
    log_in_as(@user)
    get edit_user_path(@user)
    assert_template 'users/edit'
    patch user_path(@user), params: { user: { name: '',
                                              email: 'invalid@invalid',
                                              password: 'foo',
                                              password_confirmation: 'bar' }}
    assert_template 'users/edit'
    assert_select 'div#error_explanation'
  end

  test 'successful edit' do
    log_in_as(@user)
    get edit_user_path(@user)
    assert_template 'users/edit'
    name = 'Foo Bar'
    email = 'foo@example.com'
    patch user_path(@user), params: { user: { name: name,
                                              email: email,
                                              password: '',
                                              password_confirmation: '' }}
    assert_not flash.empty?
    assert_redirected_to @user
    @user.reload
    assert_equal name, @user.name
    assert_equal email, @user.email
  end

 test 'friendly forwarding to the edit view after login' do
   get edit_user_path(@user)
   assert_redirected_to login_url
   log_in_as(@user)
   assert_redirected_to edit_user_url(@user)
 end
end
