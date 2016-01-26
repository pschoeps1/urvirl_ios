class UnblockUserService

  attr_reader :hash, :client


  def initialize client, options
    @client = client
    
    blocked_id = options.fetch :blocked_id
    auth_token = MotionKeychain.get('auth_token')

    @url = "http://mighty-mesa-2159.herokuapp.com/v1/blocked_users/destroy?auth_token=#{auth_token}&blocked_id=#{blocked_id}"
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
                  :handle_submission_failed
                when 200..299
                  :handle_unblock_user_successful
              end

    client.send method
  end

end