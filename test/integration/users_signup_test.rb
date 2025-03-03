require 'test_helper'

class UsersSignupTest < ActionDispatch::IntegrationTest

  # 無効な新規登録の情報を送信したとき
  test "invalid signup information" do
    get signup_path
    assert_no_difference 'User.count' do
    post signup_path, params: { user: { name:  "",
                                         email: "user@invalid",
                                         password:              "foo",
                                         password_confirmation: "bar" } }
    end
    assert_template 'users/new'
    assert_select "div#error_explanation"
    assert_select "div.field_with_errors"
    
    # formのpost先が"/signup"かどうか
    assert_select 'form[action="/signup"]'
  end
  
  # 有効な新規登録の情報を送信したとき
  test "valid signup information" do
    get signup_path
    assert_difference 'User.count', 1 do
      post users_path, params: { user: { name:  "Example User",
                                         email: "user@example.com",
                                         password:              "2passwordPass$",
                                         password_confirmation: "2passwordPass$" } }
    end
    # POSTリクエストを送信した結果を見て、指定されたリダイレクト先に移動する
    follow_redirect!
    
    # ルートのビューが表示されるか（あとで変更する）
    assert_template 'static_pages/arazin'
    
    # フラッシュメッセージが空ではないか
    assert_not flash.empty?
    
    # ログインしているか
    assert is_logged_in?
  end
end