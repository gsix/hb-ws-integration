class Task < ApplicationRecord
  include ::ActiveRecordConcern

  belongs_to :user_to, foreign_key: 'user_to_id', class_name: 'AdminUser'

  scope :with_user_from, -> (user) { where(user_from: user) }
  scope :with_user_to, -> (user) { where(user_to: user) }

  validates :page, presence: true, uniqueness: true

  def self.build_tasks_for_user(current_admin_user)
    client = Worksection::Client.new(Rails.application.credentials.production[:domain_name],
                                     Rails.application.credentials.production[:worksection_key])
    user_tasks = client.get_all_tasks({show_subtasks: 1}).deep_symbolize_keys[:data]
                     .select{|x| x[:user_to][:email].eql?(current_admin_user.email)}
                     .reduce([]) do |sum,x|
      x[:user_to] = current_admin_user
      x.except!(:user_from, :date_added, :priority, :date_closed, :date_end, :tags, :date_start)
      sum.push(x)
    end
    user_tasks.map{|u_p| Project.where(page: u_p[:page]).update_or_create(u_p)}
  end
end