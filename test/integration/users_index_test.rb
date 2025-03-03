require 'test_helper'

class UsersIndexTest < ActionDispatch::IntegrationTest

  def setup
    @admin     = users(:michael)
    @non_admin = users(:archer)
  end
  
  # 管理者としてindexへアクセス、ユーザーを削除
  test "index as admin including pagination and delete links" do
    log_in_as(@admin)
    assert is_logged_in?
    get users_path
    assert_template 'users/index'
    assert_select 'div.pagination'
    first_page_of_users = User.page(1)
    first_page_of_users.each do |user|
      assert_select 'a[href=?]', user_path(user), text: user.name
      
      # 管理者には削除リンクをださない(管理者を消させない)
      unless user == @admin
        assert_select 'a[href=?]', user_path(user), text: 'delete'
      end
    end
    assert_difference 'User.count', -1 do
      delete user_path(@non_admin)
    end
  end

  # 管理者ではないユーザーがindexへアクセス
  test "index as non-admin" do
    log_in_as(@non_admin)
    get users_path
    assert_select 'a', text: 'delete', count: 0
  end
end