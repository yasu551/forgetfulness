class TasksController < ApplicationController
  before_action :set_task, only: %i[edit update destroy]

  def index
    @tasks = current_user.tasks.default_order
  end

  def new
    @task = current_user.tasks.build(scheduled_at: Time.current)
  end

  def create
    @task = current_user.tasks.build(task_params)
    if @task.save
      redirect_to tasks_path, notice: "Task was successfully created."
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @task.update(task_params)
      redirect_to tasks_path, notice: "Task was successfully updated."
    else
      render :edit
    end
  end

  def destroy
    @task.destroy!
    redirect_to tasks_path, notice: "Task was successfully destroyed."
  end

  private

  def task_params
    params.require(:task).permit(:content, :scheduled_at)
  end

  def set_task
    @task = current_user.tasks.find(params[:id])
  end
end
