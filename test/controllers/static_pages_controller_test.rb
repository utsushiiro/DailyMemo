require 'test_helper'

class StaticPagesControllerTest < ActionDispatch::IntegrationTest
  def setup
    @base_title = 'DairyMemo'
  end

  test 'should get root' do
    get root_url
    assert_response :success
  end

  test 'should get about' do
    get about_url
    assert_response :success
    assert_select 'title', full_title('About')
  end

  test 'should get help' do
    get help_url
    assert_response :success
    assert_select 'title', full_title('Help')
  end

  test 'should get contact' do
    get contact_url
    assert_response :success
    assert_select 'title', full_title('Contact')
  end
end
