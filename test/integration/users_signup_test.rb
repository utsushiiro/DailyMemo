require 'test_helper'

class UsersSignupTest < ActionDispatch::IntegrationTest

  def setup
    ActionMailer::Base.deliveries.clear
  end

  test 'invalid signup information' do
    get signup_url
    assert_select 'form[action="/signup"]'
    assert_no_difference 'User.count' do
      post signup_path, params: { user: { name: '', email: 'user@invalid',
                                password: 'foo', password_confirmation: 'bar'} }

    end
    assert_template 'users/new'
    assert_select 'div#error_explanation'
    assert_select 'div.field_with_errors', count: 8
  end

  test 'valid signup information' do
    get signup_url
    assert_difference 'User.count', 1 do
      post signup_path,  params: { user: { name: 'Example User',
                                           email: 'user@example.com',
                                           password:              'password',
                                           password_confirmation: 'password' } }
    end
    assert_redirected_to root_url
    assert_equal 1, ActionMailer::Base.deliveries.size
    user = assigns(:user)
    assert_not user.activated?

    # try to log in when not activated
    log_in_as(user)
    assert_not is_logged_in?

    # follow a bad activation link(incorrect token)
    get edit_account_activation_url('Invalid token', email: user.email)
    assert_not user.reload.activated?
    assert_not is_logged_in?

    # follow a bad activation link(incorrect email)
    get edit_account_activation_url(user.activation_token, email: 'Wrong Email')
    assert_not is_logged_in?

    # follow the correct link
    get edit_account_activation_url(user.activation_token, email: user.email)
    assert user.reload.activated?
    assert is_logged_in?
    assert_redirected_to user
    follow_redirect!
    assert_template 'users/show'
    assert is_logged_in?
  end
end
