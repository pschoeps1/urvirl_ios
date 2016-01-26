class GroupEditService

  attr_reader :hash, :client

  def initialize client, options
    @client = client
    group_name = options.fetch :group_name
    group_owner = options.fetch :group_owner 
    group_description = options.fetch :group_description 
    auth_token = options.fetch :auth_token
    privacy = options.fetch :privacy
    members_events = options.fetch :members_events
    group_id = options.fetch :group_id
    
    @url = "http://mighty-mesa-2159.herokuapp.com/v1/groups/#{group_id}/edit?group_name=#{group_name}&group_owner=#{group_owner}&group_description=#{group_description}&privacy=#{privacy}&members_events=#{members_events}&auth_token=#{auth_token}&group_id=#{group_id}"
    
  end

  def process
    url = @url
    SVProgressHUD.showWithMaskType(SVProgressHUDMaskTypeClear)
    
    BW::HTTP.get(url) do |response|
      SVProgressHUD.dismiss
      handle_response response
    end
  end

  private

  def handle_response response

    method =  case response.status_code
                when 401
                  :handle_group_edit_failed
                when 200..299
                  :handle_group_edit_successful
                when 500..599
                  :handle_server_error
              end

    client.send method

  end


end