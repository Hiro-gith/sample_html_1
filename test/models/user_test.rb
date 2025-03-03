require 'test_helper'

class UserTest < ActiveSupport::TestCase
  def setup
    @user = User.new(name: "Example User", email: "user@example.com",
                     password: "1foobarFoo$", password_confirmation: "1foobarFoo$")
  end

  # 名前が空白ならfalse
  test "name should be present" do
    @user.name = "     "
    assert_not @user.valid?
  end
  
   # メールアドレスが空白ならfalse
  test "email should be present" do
    @user.email = "     "
    assert_not @user.valid?
  end
  
  # 名前が51文字以上ならfalse
   test "name should not be too long" do
    @user.name = "a" * 51
    assert_not @user.valid?
  end

  # メールアドレスが257文字以上ならfalse
  test "email should not be too long" do
    @user.email = "a" * 257 + "@example.com"
    assert_not @user.valid?
  end
  
  # 有効なメールアドレスの型
  test "email validation should accept valid addresses" do
    valid_addresses = %w[user@example.com USER@foo.COM A_US-ER@foo.bar.org
                         first.last@foo.jp alice+bob@baz.cn]
    valid_addresses.each do |valid_address|
      @user.email = valid_address
      
      # どのメールアドレスが失敗したのかを第2引数で特定する
      assert @user.valid?, "#{valid_address.inspect} should be valid"
    end
  end
  
  # 無効なメールアドレスの型
  test "email validation should reject invalid addresses" do
    invalid_addresses = %w[user@example,com user_at_foo.org user.name@example.
                           foo@bar_baz.com foo@bar+baz.com foo@bar..com]
    invalid_addresses.each do |invalid_address|
      @user.email = invalid_address
      assert_not @user.valid?, "#{invalid_address.inspect} should be invalid"
    end
  end
  
  # メールアドレスが一意でなければfalse
   test "email addresses should be unique" do
    duplicate_user = @user.dup
    duplicate_user.email = @user.email.upcase #大文字にする（大文字小文字を区別しない）
    @user.save
    assert_not duplicate_user.valid?
  end
  
  # save前にメールアドレス小文字化がされていなければfalse
  test "email addresses should be saved as lower-case" do
    mixed_case_email = "Foo@ExAMPle.CoM"
    @user.email = mixed_case_email
    @user.save
    assert_equal mixed_case_email.downcase, @user.reload.email
  end
  
  # パスワードが空ならfalse
  test "password should be present (nonblank)" do
    @user.password = @user.password_confirmation = " " * 6
    assert_not @user.valid?
  end
  
  # パスワードが8文字以下ならfalse
  test "password should have a minimum length" do
    @user.password = @user.password_confirmation = "a" * 8
    assert_not @user.valid?
  end
  
  # 記憶トークンが空白ならfalse
  test "authenticated? should return false for a user with nil digest" do
    assert_not @user.authenticated?('')
  end
  
  # ユーザーが削除されたら、itemsも消される
  test "associated items should be destroyed" do
    @user.save
    @user.items.create!(name:"aa",category:"bb",content: "Lorem ipsum", price:0,user_id: @user.id)
    assert_difference 'Item.count', -1 do
      @user.destroy
    end
  end
  
  # “following” 関連のメソッドをテスト
  test "should follow and unfollow a user" do
    michael = users(:michael)
    archer  = users(:archer)
    assert_not michael.following?(archer)
    michael.follow(archer)
    assert archer.followers.include?(michael)
    assert michael.following?(archer)
    michael.unfollow(archer)
    assert_not michael.following?(archer)
  end
end
