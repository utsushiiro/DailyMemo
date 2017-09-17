require 'test_helper'

class PasswordResetsTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:test_user)
  end

  test 'password_resets' do

    # password reset request form
    get new_password_reset_path
    assert_template 'password_resets/new'

    ## invalid mail address (no user exists)
    post password_resets_path, params: { password_reset: { email: '' } }
    assert_not_empty flash
    assert_template 'password_resets/new'

    ## valid mail address (user exists)
    post password_resets_path, params: { password_reset: { email: @user.email } }
    assert_not_equal @user.reset_digest, @user.reload.reset_digest
    assert_equal 1, ActionMailer::Base.deliveries.size
    assert_not_empty flash
    assert_redirected_to root_url

    # password reset form
    user = assigns(:user)

    ## invalid mail address
    get edit_password_reset_path(user.reset_token, email: '')
    assert_redirected_to root_url

    ## valid email address but non-activated user
    user.toggle!(:activated)
    get edit_password_reset_path(user.reset_token, email: user.email)
    assert_redirected_to root_url
    user.toggle!(:activated)

    ## valid email address & activated user but invalid token
    get edit_password_reset_path('wrong token', email: user.email)
    assert_redirected_to root_url

    ## valid get request
    get edit_password_reset_path(user.reset_token, email: user.email)
    assert_template 'password_resets/edit'
    assert_select 'input[name=email][type=hidden][value=?]', user.email

    ## invalid password & invalid password_confirmation
    patch password_reset_path(user.reset_token), params: {
                                        email: user.email,
                                        user: {
                                          password: 'hoge',
                                          password_confirmation: 'fuga' }
                                        }
    assert_select 'div#error_explanation'

    ## invalid password (empty string)
    patch password_reset_path(user.reset_token), params: {
                                        email: user.email,
                                        user: {
                                          password: '',
                                          password_confirmation: '' }
                                        }
    assert_select 'div#error_explanation'

    ## valid patch request
    patch password_reset_path(user.reset_token), params: {
                                        email: user.email,
                                        user: {
                                          password: 'hogehoge',
                                          password_confirmation: 'hogehoge' }
                                        }
    assert is_logged_in?
    assert_nil user.reload.reset_digest
    assert_not_empty flash
    assert_redirected_to user
  end

  test 'expired token' do
    get new_password_reset_path
    post password_resets_path,
         params: { password_reset: { email: @user.email} }

    @user = assigns(:user)
    @user.update_attribute(:reset_sent_at, 3.hours.ago)
    patch password_reset_path(@user.reset_token), params: {
        email: @user.email,
        user: {
            password:              'foobar',
            password_confirmation: 'foobar'
        }
    }
    assert_response :redirect
    follow_redirect!
    assert_match /expired/i, response.body
  end
end
