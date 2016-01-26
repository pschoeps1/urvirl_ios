class SignupService

  attr_reader :hash, :client
  
  API_LOGIN_END_POINT = 'http://mighty-mesa-2159.herokuapp.com/v1/users'


  def initialize client, options
    @client = client
    email = options.fetch :email
    password = options.fetch :password
    password_confirmation = options.fetch :password_confirmation
    name = options.fetch :name
    device_id = options.fetch :device_id

    @hash = { user: { email: email, password: password, password_confirmation: password_confirmation, username: name, device_id: device_id } }
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
                  :handle_signup_failed
                when 200..299
                  :handle_signup_successful
                when 500..598
                  :handle_server_error
                when 599
                  :handle_email_taken
              end

    client.send method
    dict = JSONService.parse_from_object(response.body)
    user = User.new(dict)
  end


end