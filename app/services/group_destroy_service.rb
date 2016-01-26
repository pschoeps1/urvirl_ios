class GroupDestroyService

  attr_reader :hash, :client


  def initialize client, options
    @client = client
    
    auth_token = options.fetch :auth_token
    group_id = options.fetch :group_id


    @url = "http://mighty-mesa-2159.herokuapp.com/v1/groups/#{group_id}?auth_token=#{auth_token}"
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
                  :handle_groupdestroy_failed
                when 200..299
                  :handle_groupdestroy_successful
              end

    client.send method
  end

end