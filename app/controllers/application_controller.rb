class ApplicationController < ActionController::Base
  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :first_task

  private

  def configure_permitted_parameters
    added_attrs = [ :name, :email, :password, :password_confirmation ]
    devise_parameter_sanitizer.permit :sign_up, keys: added_attrs
    devise_parameter_sanitizer.permit :account_update, keys: added_attrs
  end

  def after_sign_in_path_for(resorce)
    tasks_path
  end

  def first_task
    task = Task.joins(:reads).order(read_on: :desc).limit(1)
    @first_task = task[0]
  end
end
