class FriendAcceptService

  attr_reader :hash, :client


  def initialize client, options
    @client = client
    
    auth_token = options.fetch :auth_token
    friend_id = options.fetch :friend_id
    id = options.fetch :id


    @url = "http://mighty-mesa-2159.herokuapp.com/v1/friendships/#{id}/accept?auth_token=#{auth_token}&friend_id=#{friend_id}"
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
                  :handle_friend_accept_failed
                when 200..299
                  :handle_friend_accept_successful
              end

    client.send method
  end

end