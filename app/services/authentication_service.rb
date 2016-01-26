class AuthenticationService

  attr_reader :hash, :client
  
  API_LOGIN_END_POINT = 'http://mighty-mesa-2159.herokuapp.com/v1/users/sign_in'


  def initialize client, options
    @client = client

    email = options.fetch :email
    #device_token = options.fetch :device_token
    password = options.fetch :password
    device_id = options.fetch :device_id

    @hash = { user: { email: email, password: password, device_id: device_id } }
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
                  :handle_login_failed
                when 200..299
                  :handle_login_successful
                when 500..599
                  :handle_server_error
              end

    client.send method
    dict = JSONService.parse_from_object(response.body)
    user = User.new(dict)
  end


end