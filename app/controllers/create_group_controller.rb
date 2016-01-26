class CreateGroupController < UIViewController
  def viewDidLoad
    super
    self.navigationController.navigationBar.hidden = false
    self.navigationController.navigationBar.tintColor = UIColor.whiteColor

    #set background color of navbar here so that it will be inherited by rest of controllers
    purple = UIColor.colorWithRed(0.306, green:0, blue:0.557, alpha:1)
    self.navigationController.navigationBar.setBarTintColor(purple)
    self.navigationController.navigationBar.setTranslucent(false)

    
    #cutsom titles to change background colors of all buttons to white
    titleView = UILabel.alloc.initWithFrame(CGRectZero)
    titleView.backgroundColor = UIColor.clearColor
    titleView.font = UIFont.boldSystemFontOfSize(20.0)
    titleView.shadowColor = UIColor.colorWithWhite(0.0,alpha:0.5)
    titleView.textColor = UIColor.whiteColor
    self.navigationItem.titleView = titleView
    titleView.text = "Create Group"
    titleView.sizeToFit

    StandardAppearance.set_named_fonts_and_colors
    rmq.stylesheet = MainStylesheet
    rmq(self.view).apply_style :root_view

    rmq.append(UIView, :group_creation_form).tap do |q|
      @group_name = q.append(UITextField, :group_name).get
      @group_owner = q.append(UITextField, :group_owner).get
      @group_description = q.append(UITextField, :group_description).get

      q.append(UIButton, :group_creation_button).on(:tap) do |_|
        if internet_connected?
          create_group
        else
          App.alert("Poor internet connection or airplane mode enabled")
        end
      end
    end

    
    #placying switches and labels outside of main form so that entire width of screen can be used
    privacy_frame = [[self.view.frame.size.width - 60, 160], [30, 30]]
    @privacy = UISwitch.alloc.initWithFrame(privacy_frame)
    @privacy.setOn(true, animated: true)
    self.view.addSubview(@privacy)

    #switch for "members can create events?"
    members_frame = [[self.view.frame.size.width - 60, 210], [30, 30]]
    @members_events = UISwitch.alloc.initWithFrame(members_frame)
    self.view.addSubview(@members_events)

    @privacy_label = rmq.append(UILabel, :privacy_label).get
    @events_label = rmq.append(UILabel, :events_label)

    @ref = Firebase.alloc.initWithUrl("https://urvirl.firebaseio.com/chat/room-metadata/")
    @user = NSUserDefaults.standardUserDefaults["id"]

  end

  def internet_connected?
    TMReachability.reachabilityForInternetConnection.isReachable
  end

  def create_group
    if submission_invalid?
      handle_invalid_submission
    else
      create_chat_room 
    end
  end

  def handle_valid_submission(group_name)
  	
  	if @privacy.isOn
  		privacy = true
  	else
  		privacy = false
  	end

  	if @members_events.isOn
  		members_events = true
  	else
  		members_events = false
  	end

  	chat_id = group_name
  	

    process_create_group @group_name.text, @group_owner.text, @group_description.text, privacy, members_events, chat_id
  end

  def process_create_group(group_name, group_owner, group_description, privacy, members_events, chat_id)
    auth_token = MotionKeychain.get('auth_token')

    GroupCreationService.new(self, {group_name: group_name, group_owner: group_owner, group_description: group_description, privacy: privacy, members_events: members_events, chat_id: chat_id, auth_token: auth_token }).process
  end

  def handle_group_creation_failed
    App.alert('Group creation failed, please try again')
  end

  def handle_group_creation_successful
    new_controller = GroupsController.alloc.initWithStyle(UITableViewStylePlain)
    self.navigationController.pushViewController(new_controller, animated: true)
  end

  def handle_server_error
    App.alert('something went wrong')
  end

  def submission_invalid?
    @group_name.text.blank?
  end

  def handle_invalid_submission
    if @group_name.text.blank?
      App.alert 'Please enter a name for you group'
    end
  end

  def create_chat_room
  	ref = @ref
  	id = @user
  	name = @group_name.text
  	newobj = ref.push({ name: name, createdByUserId: id, type: "public" })
    group_name = newobj.name
    ref.child(group_name).update({ id: group_name })
    handle_valid_submission(group_name)
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

end

