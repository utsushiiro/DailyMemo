require 'test_helper'

class UsersIndexTest < ActionDispatch::IntegrationTest
  def setup
    @admin = users(:test_user)
    @non_admin = users(:another_test_user)
    @will_delete_test_user = users(:will_deleted_test_user)
  end

  test 'index as admin including pagination and delete links' do
    log_in_as(@admin)
    get users_path
    assert_template 'users/index'
    assert_select 'div.pagination'
    User.paginate(page: 1).each do |user|
      assert_select 'ul.users a[href=?]', user_path(user), text: user.name
      unless user == @admin
        assert_select 'ul.users a[href=?]', user_path(user), text: 'delete'
      end
    end

    assert_difference 'User.count', -1 do
      delete user_path(@will_delete_test_user)
    end
  end

  test 'index as non-admin' do
    log_in_as(@non_admin)
    get users_path
    assert_select 'ul.users a', text: 'delete', count: 0
  end
end
