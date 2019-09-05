class AddTaskToProject < ActiveRecord::Migration[5.2]
  def change
    add_reference :projects, :task, foreign_key: true
    add_reference :tasks, :project, foreign_key: true
  end
end
