class GroupEventDestroyService

  attr_reader :hash, :client


  def initialize client, options
    @client = client
    
    auth_token = options.fetch :auth_token
    event_id = options.fetch :event_id
    group_id = options.fetch :group_id


    @url = "http://mighty-mesa-2159.herokuapp.com/v1/groups/#{group_id}/events/#{event_id}?auth_token=#{auth_token}"
  end

  def process
    url = @url
    SVProgressHUD.showWithMaskType(SVProgressHUDMaskTypeClear)

    BW::HTTP.delete(url) do |response|
      SVProgressHUD.dismiss
      handle_response response
    end
  end

  private

  def handle_response response

    method =  case response.status_code
                when 401 || 500..599
                  :handle_eventdestroy_failed
                when 200..299
                  :handle_eventdestroy_successful
              end

    client.send method
  end

end