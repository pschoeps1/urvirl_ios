class EventCreationService

  attr_reader :hash, :client


  def initialize client, options
    @client = client
    
    auth_token = options.fetch :auth_token
    group_id = options.fetch :group_id
    start_at = options.fetch :start_at
    end_at = options.fetch :end_at
    content = options.fetch :content
    name = options.fetch :name

    @url = "http://mighty-mesa-2159.herokuapp.com/v1/groups/#{group_id}/events?group_id=#{group_id}&auth_token=#{auth_token}&start_at=#{start_at}&end_at=#{end_at}&content=#{content}&name=#{name}"
  end

  def process
    url = @url
    SVProgressHUD.showWithMaskType(SVProgressHUDMaskTypeClear)

    BW::HTTP.post(url) do |response|
      SVProgressHUD.dismiss
      handle_response response
    end
  end

  private

  def handle_response response

    method =  case response.status_code
                when 401 || 500..599
                  :handle_event_creation_failed
                when 200..299
                  :handle_event_creation_successful
              end

    client.send method
  end

end