class UpdateTaskItemsJob < ApplicationJob
  queue_as :default

  def perform(task_id:)
    task = Task.find_by(id: task_id)
    return if task.blank?

    task.update_items!
  end
end
