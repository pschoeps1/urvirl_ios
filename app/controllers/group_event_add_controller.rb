class GroupEventAddController < UIViewController
  def viewDidLoad
    super
    self.navigationController.navigationBar.hidden = false
    self.navigationController.navigationBar.tintColor = UIColor.whiteColor

    self.view.frame.size.height = 1000

    frame = UIScreen.mainScreen.bounds
    origin = frame.origin
    size = frame.size



    rightButton = UIBarButtonItem.alloc.initWithTitle("Cancel",style:UIBarButtonItemStyleDone,target: self,action:'resign_keyboard')
    self.navigationItem.rightBarButtonItem = rightButton

    leftButton = UIBarButtonItem.alloc.initWithTitle("Back",style:UIBarButtonItemStyleDone,target: self,action:'go_back')
    self.navigationItem.leftBarButtonItem = leftButton

    #set background color of navbar here so that it will be inherited by rest of controllers
    purple = UIColor.colorWithRed(0.306, green:0, blue:0.557, alpha:1)
    self.navigationController.navigationBar.setBarTintColor(purple)
    self.navigationController.navigationBar.setTranslucent(false)
    self.navigationItem.setHidesBackButton(true)

    
    #cutsom titles to change background colors of all buttons to white
    titleView = UILabel.alloc.initWithFrame(CGRectZero)
    titleView.backgroundColor = UIColor.clearColor
    titleView.font = UIFont.boldSystemFontOfSize(20.0)
    titleView.shadowColor = UIColor.colorWithWhite(0.0,alpha:0.5)
    titleView.textColor = UIColor.whiteColor
    self.navigationItem.titleView = titleView
    titleView.text = "Create Event"
    titleView.sizeToFit

    StandardAppearance.set_named_fonts_and_colors
    rmq.stylesheet = MainStylesheet
    rmq(self.view).apply_style :root_view

    rmq.append(UIView, :event_creation_form).tap do |q|
      @event_name = q.append(UITextField, :event_name).get
      @start_at_label = q.append(UILabel, :start_at_label).get
      @start_at = q.append(UIDatePicker, :start_at).get
      @end_at_label = q.append(UILabel, :end_at_label).get
      @end_at = q.append(UIDatePicker, :end_at).get
      @event_content = q.append(UITextField, :event_content).get

      q.append(UIButton, :event_creation_button).on(:tap) do |_|
        if internet_connected?
          create_event
        else
          App.alert("Poor internet connection or airplane mode enabled")
        end
      end
    end

   @email = MotionKeychain.get('email')
   @auth_token = MotionKeychain.get('auth_token')
   @user = NSUserDefaults.standardUserDefaults["id"]
   @name = MotionKeychain.get('name')
   @group = NSUserDefaults.standardUserDefaults["group-id"]

  end

  def internet_connected?
    TMReachability.reachabilityForInternetConnection.isReachable
  end

  def create_event
    if submission_invalid?
      handle_invalid_submission
    else
      handle_valid_submission
    end
  end

  def handle_valid_submission
    outputFormatter = NSDateFormatter.alloc.init
    enUSPOSIXLocale = NSLocale.localeWithLocaleIdentifier("en_US_POSIX")
    outputFormatter.setLocale(enUSPOSIXLocale)
    outputFormatter.setDateFormat("yyyy-MM-dd'T'HH:mm:ssZZZZZ")
    start_at = outputFormatter.stringFromDate(@start_at.date)
    end_at = outputFormatter.stringFromDate(@end_at.date)

    process_create_event @event_name.text, start_at, end_at, @event_content.text
  end

  def process_create_event(name, start_at, end_at, content)
    auth_token = MotionKeychain.get('auth_token')
    group_id = @group

    EventCreationService.new(self, {name: name, start_at: start_at, end_at: end_at, content: content, group_id: group_id, auth_token: auth_token }).process
  end

  def handle_event_creation_failed
    App.alert('Event creation failed, please try again')
  end

  def handle_event_creation_successful
    new_controller = GroupEventsController.alloc.initWithStyle(UITableViewStylePlain)
    self.navigationController.pushViewController(new_controller, animated: true)
  end

  def handle_server_error
    App.alert('something went wrong')
  end

  def submission_invalid?
    @event_name.text.blank? || @start_at.date.blank?
  end

  def handle_invalid_submission
      App.alert 'Name and start date required.'
  end


  def register_keyboard_events
    NSNotificationCenter.defaultCenter.addObserver(self, selector: "keyboardWillHide:", name: :UIKeyboardWillHideNotification, object: nil)
    NSNotificationCenter.defaultCenter.addObserver(self, selector: "keyboardWillShow:", name: :UIKeyboardWillShowNotification, object: nil)
  end


  def unregister_keyboard_events
    NSNotificationCenter.defaultCenter.removeObserver(self)
  end

  def keyboardWillShow(notification)
    keyboard_rect_ptr = Pointer.new(CGRect.type)
    notification.userInfo.valueForKey('UIKeyboardFrameEndUserInfoKey').getValue(keyboard_rect_ptr)
    duration = notification.userInfo.valueForKey('UIKeyboardAnimationDurationUserInfoKey').floatValue
    keyboard_rect = keyboard_rect_ptr[0]
    y = keyboard_rect.size.height * -1
    up_position = CGRectOffset(self.view.frame, 0, y)
    if self.view.frame.size.height == @table.frame.size.height + y
      #do nothing
    else
      UIView.animateWithDuration(duration,animations: lambda { self.view.setFrame(up_position) },completion: lambda {|finished| })
    end 
  end


  def keyboardWillHide(notification)
    keyboard_rect_ptr = Pointer.new(CGRect.type)
    notification.userInfo.valueForKey('UIKeyboardFrameEndUserInfoKey').getValue(keyboard_rect_ptr)
    duration = notification.userInfo.valueForKey('UIKeyboardAnimationDurationUserInfoKey').floatValue
    keyboard_rect = keyboard_rect_ptr[0]
    y = keyboard_rect.size.height 
    down_position = CGRectOffset(self.view.frame, 0, y)
    UIView.animateWithDuration(duration,animations: lambda { self.view.setFrame(down_position) },completion: lambda {|finished| }) 
  end

  def resign_keyboard
    #@group_invited.resignFirstResponder
    self.view.endEditing(true)
  end 

  def go_back
    new_controller = GroupEventsController.alloc.initWithStyle(UITableViewStylePlain)
    self.navigationController.pushViewController(new_controller, animated: true)
  end

end

