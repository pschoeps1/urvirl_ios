class GroupCreationService

  attr_reader :hash, :client
  
  API_LOGIN_END_POINT = 'http://mighty-mesa-2159.herokuapp.com/v1/groups'


  def initialize client, options
    @client = client
    group_name = options.fetch :group_name
    group_owner = options.fetch :group_owner 
    group_description = options.fetch :group_description 
    chat_id = options.fetch :chat_id
    auth_token = options.fetch :auth_token
    privacy = options.fetch :privacy
    members_events = options.fetch :members_events

    @hash = { group_name: group_name, group_owner: group_owner, group_description: group_description, chat_id: chat_id, privacy: privacy, members_events: members_events, auth_token: auth_token } 
  end

  def process
    SVProgressHUD.showWithMaskType(SVProgressHUDMaskTypeClear)

    payload = BW::JSON.generate(hash)
    headers = { 'Content-Type' => 'application/json' }
    
    BW::HTTP.post(API_LOGIN_END_POINT, { headers: headers, payload: payload } ) do |response|
      SVProgressHUD.dismiss
      handle_response response
    end
  end

  private

  def handle_response response

    method =  case response.status_code
                when 401
                  :handle_group_creation_failed
                when 200..299
                  :handle_group_creation_successful
                when 500..599
                  :handle_server_error
              end

    client.send method

  end


end