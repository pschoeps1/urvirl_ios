class FlagService

  attr_reader :hash, :client


  def initialize client, options
    @client = client
    
    user_id = options.fetch :user_id
    auth_token = options.fetch :auth_token
    reporter_id = options.fetch :reporter_id
    content = options.fetch :content

    @url = "http://mighty-mesa-2159.herokuapp.com/v1/flags?user_id=#{user_id}&auth_token=#{auth_token}&reporter_id=#{reporter_id}&content=#{content}"
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
                  :handle_submission_failed
                when 200..299
                  :handle_submission_successful
              end

    client.send method
  end

end