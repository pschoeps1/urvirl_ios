class GroupsService
	  attr_reader :hash, :client

    @auth_token = MotionKeychain.get('auth_token')
    auth_token = @auth_token
    @user = MotionKeychain.get('user')
    user_data = @user

	API_GROUPS_END_POINT = "http://mighty-mesa-2159.herokuapp.com/v1/users/#{user_data}/dashboard"



  def initialize client, options
    @client = client

    auth_token = options.fetch :auth_token

    @hash = { user: { auth_data: auth_token } }
  end

  def process
    SVProgressHUD.showWithMaskType(SVProgressHUDMaskTypeClear)
    
    payload = BW::JSON.generate(hash)
    headers = { 'Content-Type' => 'application/json' }
    
    BW::HTTP.post(API_GROUPS_END_POINT, { headers: headers, payload: payload } ) do |response|
      SVProgressHUD.dismiss
    end
    
  end

end