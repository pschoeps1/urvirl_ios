class LoginController < UIViewController

  def viewDidLoad
    super
    self.navigationController.navigationBar.hidden = true

    #set background color of navbar here so that it will be inherited by rest of controllers
    purple = UIColor.colorWithRed(0.306, green:0, blue:0.557, alpha:1)
    self.navigationController.navigationBar.setBarTintColor(purple)
    self.navigationController.navigationBar.setTranslucent(false)


    self.view.addSubview @label
    
    #cutsom titles to change background colors of all buttons to white
    titleView = UILabel.alloc.initWithFrame(CGRectZero)
    titleView.backgroundColor = UIColor.clearColor
    titleView.font = UIFont.boldSystemFontOfSize(20.0)
    titleView.shadowColor = UIColor.colorWithWhite(0.0,alpha:0.5)
    titleView.textColor = UIColor.whiteColor
    self.navigationItem.titleView = titleView
    titleView.text = "Login"
    titleView.sizeToFit

    StandardAppearance.set_named_fonts_and_colors
    rmq.stylesheet = MainStylesheet
    rmq(self.view).apply_style :root_view

    rmq.append(UIView, :header) do |q|
      @label = q.append(UILabel, :label).get
    end

    rmq.append(UILabel, :logo).get


    rmq.append(UIView, :login_form).tap do |q|
      @email = q.append(UITextField, :email).get
      @password = q.append(UITextField, :password).get

      q.append(UIButton, :login_button).on(:tap) do |_|
        if internet_connected?
          login
        else
          App.alert("Poor internet connection or airplane mode enabled")
        end
      end
    end

    rmq.append(UILabel, :privacy_policy_link).on(:tap) do |_|
      privacy_policy_link
    end

    rmq.append(UILabel, :sign_up_link).on(:tap) do |_|
      sign_up_link
    end
    register_push_notifications  
  end

  def internet_connected?
    TMReachability.reachabilityForInternetConnection.isReachable
  end

  def privacy_policy_link
    new_controller = PrivacyPolicyController.alloc.initWithNibName(nil, bundle: nil)
    self.navigationController.pushViewController(new_controller, animated: true)
  end

  def sign_up_link
    new_controller = SignupController.alloc.initWithNibName(nil, bundle: nil)
    self.navigationController.pushViewController(new_controller, animated: true)
  end

  def login
    if submission_invalid?
      handle_invalid_submission
    else
      handle_valid_submission
    end
  end

  def handle_valid_submission
    process_authentication @email.text, App::Persistence['device_token'], @password.text
  end

  def process_authentication(email, device_token, password)
    device_id = MotionKeychain.get('device_id')
    MotionKeychain.set('password', password)
    AuthenticationService.new(self, {email: email, password: password, device_id: device_id}).process
  end

  def handle_login_failed
    App.alert('login failed')
  end

  def handle_login_successful
    new_controller = GroupsController.alloc.initWithStyle(UITableViewStylePlain)
    self.navigationController.pushViewController(new_controller, animated: true)
  end

  def handle_server_error
    App.alert('something went wrong')
  end

  def submission_invalid?
    @email.text.blank? || @password.text.blank?
  end

  def handle_invalid_submission
    if @email.text.blank?
      App.alert 'Please enter email'
    elsif @password.text.blank?
      App.alert 'Please enter password'
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

end

