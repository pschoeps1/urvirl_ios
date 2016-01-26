class BlockedUsersService

attr_reader :hash, :client


  def initialize client, options
    @client = client
    
    
    auth_token = options.fetch :auth_token

    @url = "http://mighty-mesa-2159.herokuapp.com/v1/blocked_users/show?auth_token=#{auth_token}"
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
                when 401 || 500..599
                  :handle_submission_failed
                when 200..299
                  :process_blocked_users
              end

    client.send method(response)
  end

end