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
    if @first_task
      task_path(@first_task.id)
    else
      tasks_path
    end
  end

  def first_task
    if user_signed_in?
      task = current_user.tasks.joins(:reads).order(read_on: :desc).limit(1)
      @first_task = task[0]
    end
  end
end
