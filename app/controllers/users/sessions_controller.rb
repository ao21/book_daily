class Users::SessionsController < Devise::SessionsController
  def guest_sign_in
    user = User.guest
    sign_in user
    redirect_to today_tasks_path, notice: 'ゲストユーザーとしてログインしました。'
  end
end