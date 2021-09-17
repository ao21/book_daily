module ApplicationHelper

  # ユーザーのタスク登録の有無に応じてリンク先を分ける
  def link_task_show_or_index
    if user_signed_in?
      if @first_task # application_controllerで定義
        task_path(@first_task.id)
      else
        tasks_path
      end
    end
  end
end
