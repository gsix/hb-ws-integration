ActiveAdmin.register Project do
  action_item :view_site do
    #link_to "Sync Projects", admin_projects_sync_path, remote: true, class: 'synchronize_button'
  end

  controller do
    def sync
      Project.build_projects_for_user(current_admin_user)
    end

    def scoped_collection
      current_admin_user.projects
    end
  end
end