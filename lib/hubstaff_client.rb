class HubstaffClient
  def initialize
  end

  def task_create access_token, project_id, title, assignee_id
    HTTParty.post("https://api.hubstaff.com/v2/projects/#{project_id}/tasks", {
      body: {
        summary: title,
        assignee_id: assignee_id
      }.to_json,
      headers: {
        'Content-Type' => 'application/json',
        Accept: 'application/json',
        Authorization: "Bearer #{access_token}"
      }
    })
  end

  def task_update access_token, task_id, title, assignee_id, lock_version
    HTTParty.put("https://api.hubstaff.com/v2/tasks/#{task_id}", {
      body: {
        summary: title,
        lock_version: lock_version,
        assignee_id: assignee_id
      }.to_json,
      headers: {
        'Content-Type' => 'application/json',
        Accept: 'application/json',
        Authorization: "Bearer #{access_token}"
      }
    })
  end

  def task_delete access_token, task_id
    HTTParty.delete("https://api.hubstaff.com/v2/tasks/#{task_id}", {
      headers: {
        Accept: 'application/json',
        Authorization: "Bearer #{access_token}"
      }
    })
  end

  def organization_tasks access_token, organization_id
    HTTParty.get("https://api.hubstaff.com/v2/organizations/#{organization_id}/tasks", {
      headers: {
        Accept: 'application/json',
        Authorization: "Bearer #{access_token}"
      }
    })
  end

  def organization_projects access_token, organization_id
    HTTParty.get("https://api.hubstaff.com/v2/organizations/#{organization_id}/projects", {
      headers: {
        Accept: 'application/json',
        Authorization: "Bearer #{access_token}"
      }
    })
  end

  def organization_project_create access_token, organization_id, name, members = []
    HTTParty.post("https://api.hubstaff.com/v2/organizations/#{organization_id}/projects", {
      body: {
        name: name,
        members: members
      }.to_json,
      headers: {
        'Content-Type' => 'application/json',
        Accept: 'application/json',
        Authorization: "Bearer #{access_token}"
      }
    })
  end

  def organization_members access_token, organization_id
    HTTParty.get("https://api.hubstaff.com/v2/organizations/#{organization_id}/members", {
      headers: {
        Accept: 'application/json',
        Authorization: "Bearer #{access_token}"
      }
    })
  end

  def organization_user access_token, user_id
    HTTParty.get("https://api.hubstaff.com/v2/users/#{user_id}", {
      headers: {
        Accept: 'application/json',
        Authorization: "Bearer #{access_token}"
      }
    })
  end

  def organization_activities(access_token, organization_id, hours_ago: 1)
    start_time = (DateTime.now - hours_ago.hours).utc.iso8601
    stop_time = DateTime.now.utc.iso8601

    HTTParty.get("https://api.hubstaff.com/v2/organizations/#{organization_id}/activities?time_slot[start]=#{start_time}&time_slot[stop]=#{stop_time}", {
      headers: {
        Accept: 'application/json',
        Authorization: "Bearer #{access_token}"
      }
    })
  end

  def access_token_request code
    HTTParty.post("https://account.hubstaff.com/access_tokens?grant_type=authorization_code&code=#{code}&redirect_uri=#{configs[:app_redirect_url]}", {
      basic_auth: { username: configs[:app_client_id], password: configs[:app_client_secret] }
    })
  end

  def refresh_access_token_request refresh_token
    HTTParty.post("https://account.hubstaff.com/access_tokens?grant_type=refresh_token&refresh_token=#{refresh_token}&scope=hubstaff:read hubstaff:write", {
      basic_auth: { username: configs[:app_client_id], password: configs[:app_client_secret] }
    })
  end

  def start_auth_code_url
    "https://account.hubstaff.com/authorizations/new?client_id=#{configs[:app_client_id]}&response_type=code&nonce=#{SecureRandom.hex}&redirect_uri=#{configs[:app_redirect_url]}&scope=hubstaff:read hubstaff:write"
  end

  def configs
    @configs ||= Rails.application.credentials[Rails.env.to_sym][:hubstaff]
  end
end
