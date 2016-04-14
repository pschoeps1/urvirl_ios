class AuthenticationController < UIViewController
	def viewDidLoad
    super
    #self.navigationItem.setHidesBackButton(true)
   #self.navigationController.navigationBar.hidden(true)

    StandardAppearance.set_named_fonts_and_colors
    rmq.stylesheet = MainStylesheet
    rmq(self.view).apply_style :root_view

    rmq.append(UILabel, :first_screen).get

    register_push_notifications  
    check_auth
  end

  def internet_connected?
    TMReachability.reachabilityForInternetConnection.isReachable
  end

  def check_auth
  	password = MotionKeychain.get('password') 
  	email = MotionKeychain.get('email')

  	if password && email && internet_connected?
  		device_id = MotionKeychain.get('device_id')
  		AuthenticationService.new(self, {email: email, password: password, device_id: device_id}).process
  	else
  	  new_controller = LoginController.alloc.initWithNibName(nil, bundle: nil)
      self.navigationController.pushViewController(new_controller, animated: true)
    end
  end  

  def register_push_notifications  
    if UIApplication.sharedApplication.respondsToSelector("registerUserNotificationSettings:")
      settings = UIUserNotificationSettings.settingsForTypes(UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound, categories: nil)
      UIApplication.sharedApplication.registerUserNotificationSettings(settings)
    else
      UIApplication.sharedApplication.registerForRemoteNotificationTypes(UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound)
    end
  end 

  def handle_login_failed
    new_controller = LoginController.alloc.initWithNibName(nil, bundle: nil)
    self.navigationController.pushViewController(new_controller, animated: true)
  end

  def handle_login_successful
    new_controller = GroupsController.alloc.initWithStyle(UITableViewStylePlain)
    self.navigationController.pushViewController(new_controller, animated: true)
  end

  def handle_server_error
    new_controller = LoginController.alloc.initWithNibName(nil, bundle: nil)
    self.navigationController.pushViewController(new_controller, animated: true)
  end


  def postHello
    App.alert("hello")
    #compile this too
  end
end

