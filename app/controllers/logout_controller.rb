class LogoutController < UIViewController

  def viewDidLoad
    super
    
    self.navigationController.navigationBar.hidden = true
    self.navigationItem.setHidesBackButton(true)



    frame = UIScreen.mainScreen.bounds
    origin = frame.origin
    size = frame.size
    text_view = UITextView.alloc.initWithFrame([[origin.x, origin.y],
                                                 [size.width, size.height]])

    logout

  end

  def logout
    email = MotionKeychain.get('email')
    auth_token = MotionKeychain.get('auth_token')
    LogoutService.new(self, {email: email, device_token: auth_token}).process
  end

  def handle_logout
    MotionKeychain.remove('auth_token')
    MotionKeychain.remove('password')
    MotionKeychain.remove('email')
    new_controller = LoginController.alloc.initWithNibName(nil, bundle: nil)
    self.navigationController.pushViewController(new_controller, animated: false)
  end
end
