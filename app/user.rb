class User
  attr_reader :user_id, :auth_token, :email, :user_name

  def initialize(dict)
    @user_id = dict['user_id']
    @auth_token = dict['auth_token']
    @email = dict['email']
    @name = dict['user_name']

   
    MotionKeychain.set('name', @name)
    MotionKeychain.set('email', @email)
    MotionKeychain.set('auth_token', @auth_token)
    NSUserDefaults.standardUserDefaults["id"] = @user_id
  end
end