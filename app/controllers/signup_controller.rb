class SignupController < UIViewController

  def viewDidLoad
    super
    self.navigationController.navigationBar.hidden = false
    self.navigationItem.setHidesBackButton(true)
    leftButton = UIBarButtonItem.alloc.initWithTitle("Back",style:UIBarButtonItemStyleDone,target: self,action:'go_back')
    self.navigationItem.leftBarButtonItem = leftButton

    self.view.addSubview @label

    titleView = UILabel.alloc.initWithFrame(CGRectZero)
    titleView.backgroundColor = UIColor.clearColor
    titleView.font = UIFont.boldSystemFontOfSize(20.0)
    titleView.shadowColor = UIColor.colorWithWhite(0.0,alpha:0.5)
    titleView.textColor = UIColor.whiteColor
    self.navigationItem.titleView = titleView
    titleView.text = 'Sign Up'
    titleView.sizeToFit

    self.navigationController.navigationBar.tintColor = UIColor.whiteColor

    StandardAppearance.set_named_fonts_and_colors
    rmq.stylesheet = MainStylesheet
    rmq(self.view).apply_style :root_view

    rmq.append(UIView, :signup_form).tap do |q|
      @name = q.append(UITextField, :name).get
      @email = q.append(UITextField, :signup_email).get
      @password = q.append(UITextField, :signup_password).get
      @password_confirmation = q.append(UITextField, :password_confirmation).get

      q.append(UIButton, :signup_button).on(:tap) do |_|
        if internet_connected?
          signup
        else
          App.alert("Poor internet connection or airplane mode enabled")
        end
      end
    end

    rmq.append(UILabel, :privacy_policy_link_signup).on(:tap) do |_|
      privacy_policy_link_signup
    end

    register_push_notifications  
  end

  def internet_connected?
    TMReachability.reachabilityForInternetConnection.isReachable
  end

  def privacy_policy_link_signup
    new_controller = PrivacyPolicyController.alloc.initWithNibName(nil, bundle: nil)
    self.navigationController.pushViewController(new_controller, animated: true)
  end

  def signup
    if submission_invalid?
      handle_invalid_submission
    else
      handle_valid_submission
    end
  end

  def handle_valid_submission
    process_signup @email.text, @password.text, @name.text, @password_confirmation.text
  end

  def process_signup(email, password, name, password_confirmation)
    device_id = MotionKeychain.get('device_id')
    MotionKeychain.set('password', password)
    SignupService.new(self, {email: email, password: password, password_confirmation: password_confirmation, device_id: device_id, name: name}).process
  end

  def handle_signup_failed
    App.alert('Sign up attempt failed')
  end

  def handle_signup_successful
    App.alert('Sign up succesful!  Head over to urvirl.com to finish completing your profile')
    new_controller = GroupsController.alloc.initWithStyle(UITableViewStylePlain)
    self.navigationController.pushViewController(new_controller, animated: true)
  end

  def handle_server_error
    App.alert('something went wrong')
  end

  def submission_invalid?
    @email.text.blank? || @password.text.blank? || @password_confirmation.text.blank? || @name.text.blank? ||  @password.text != @password_confirmation.text || @name.text.length < 6 || @password.text.length < 8 
    #@password.text != @password_confirmation.text
  end

  def handle_email_taken
    App.alert('Email taken')
  end

  def handle_invalid_submission
    if @email.text.blank?
      App.alert 'Please enter email'
    elsif @password.text.blank?
      App.alert 'Please enter password'
    elsif @name.text.blank?
      App.alert 'Please enter a name'
    elsif @password_confirmation.blank?
      App.alert 'Please enter a password confirmation'
    elsif @password_confirmation.text != @password.text
      App.alert 'You password and password confirmation do not match'
    elsif @name.text.length < 6
      App.alert 'Name must be at least 6 characters'
    elsif @password.text.length < 8
      App.alert 'Password must be at least 8 characters'
    end
      
  end

  def go_back
    new_controller = LoginController.alloc.initWithNibName(nil, bundle: nil)
    self.navigationController.pushViewController(new_controller, animated: true)
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

