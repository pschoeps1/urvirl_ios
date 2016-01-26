class LogoutService

  attr_reader :hash, :client

  API_LOGOUT_END_POINT = 'http://mighty-mesa-2159.herokuapp.com/v1/sign_out'


  def initialize client, options
    @client = client

    email = options.fetch :email
    device_token = options.fetch :device_token

    @hash = { user: { email: email, device_token: device_token } }
  end

  def process
    SVProgressHUD.showWithMaskType(SVProgressHUDMaskTypeClear)
    payload = BW::JSON.generate(hash)
    headers = { 'Content-Type' => 'application/json' }

    BW::HTTP.delete(API_LOGOUT_END_POINT, { headers: headers, payload: payload } ) do |response|
      handle_response response
      SVProgressHUD.dismiss
    end
  end

  private

  def handle_response response

    client.send :handle_logout

  end

end