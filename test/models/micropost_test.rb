require 'test_helper'

class MicropostTest < ActiveSupport::TestCase
  def setup
    @user = users(:test_user)
    @micropost = @user.microposts.build(content: 'hoge')
  end

  test 'should be valid' do
    assert @micropost.valid?
  end

  test 'user id should present' do
    @micropost.user_id = nil
    assert_not @micropost.valid?
  end

  test 'content should be present' do
    @micropost.content = nil
    assert_not @micropost.valid?
  end

  test 'content should be at most 140 characters' do
    @micropost.content = ' ' * 141
    assert_not @micropost.valid?
  end
end
