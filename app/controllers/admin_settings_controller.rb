class AdminSettingsController < UIViewController
  
  def viewDidLoad
    @data = NSMutableArray.alloc.init
    @keys = @data.map { |r| r.name }
    @email = MotionKeychain.get('email')
    @auth_token = MotionKeychain.get('auth_token')
    @user = NSUserDefaults.standardUserDefaults["id"]
    @name = MotionKeychain.get('name')
    super

    self.view.frame.size.height = 800

    rightButton = UIBarButtonItem.alloc.initWithTitle("Cancel",style:UIBarButtonItemStyleDone,target: self,action:'resign_keyboard')
    self.navigationItem.rightBarButtonItem = rightButton

    blue = UIColor.colorWithRed(0.00,green:0.64,blue:0.88,alpha:1.0)

    titleView = UILabel.alloc.initWithFrame(CGRectZero)
    titleView.backgroundColor = UIColor.clearColor
    titleView.font = UIFont.boldSystemFontOfSize(20.0)
    titleView.shadowColor = UIColor.colorWithWhite(0.0,alpha:0.5)
    titleView.textColor = UIColor.whiteColor
    self.navigationItem.titleView = titleView
    titleView.text = "Settings"
    titleView.sizeToFit

    self.navigationController.navigationBar.tintColor = UIColor.whiteColor

    StandardAppearance.set_named_fonts_and_colors
    rmq.stylesheet = MainStylesheet
    rmq(self.view).apply_style :root_view

    rmq.append(UIView, :group_edit_form).tap do |q|
      @group_name = q.append(UITextField, :group_name).get
      @group_owner = q.append(UITextField, :group_owner).get
      @group_description = q.append(UITextField, :group_description).get

      q.append(UIButton, :group_edit_button).on(:tap) do |_|
        if internet_connected?
          edit_group
        else
          App.alert("Poor internet connection or airplane mode enabled")
        end
      end
    end

    @group_name.text = NSUserDefaults.standardUserDefaults["group-name"]
    @group_owner.text = NSUserDefaults.standardUserDefaults["group-teacher"]
    @group_description.text = NSUserDefaults.standardUserDefaults["group-teacher"]
     

    
    #placying switches and labels outside of main form so that entire width of screen can be used
    privacy_frame = [[self.view.frame.size.width - 60, 160], [30, 30]]
    @privacy = UISwitch.alloc.initWithFrame(privacy_frame)
    if NSUserDefaults.standardUserDefaults["group-privacy"] == true
      @privacy.setOn(true, animated: true)
    end
    self.view.addSubview(@privacy)

    #switch for "members can create events?"
    members_frame = [[self.view.frame.size.width - 60, 210], [30, 30]]
    @members_events = UISwitch.alloc.initWithFrame(members_frame)
    if NSUserDefaults.standardUserDefaults['group-members_can_edit'] == true
        @members_events.setOn(true, animated: true)
    end
    self.view.addSubview(@members_events)

    @privacy_label = rmq.append(UILabel, :privacy_label).get
    @events_label = rmq.append(UILabel, :events_label)

    rmq.append(UIButton, :group_invite_friends_button).on(:tap) do |_|
        if internet_connected?
            invite_friends
        else
            App.alert("Poor internet connection or airplane mode enabled")
        end
    end

    rmq.append(UIButton, :group_invite_members_button).on(:tap) do |_|
        if internet_connected?
            invite_members
        else
            App.alert("Poor internet connection or airplane mode enabled")
        end
    end

    rmq.append(UIButton, :group_list_members).on(:tap) do |_|
        if internet_connected?
            list_members
        else
            App.alert("Poor internet connection or airplane mode enabled")
        end
    end

    rmq.append(UIButton, :group_destroy_button).on(:tap) do |_|
        if internet_connected?
            destroy_group_confirmation
        else
            App.alert("Poor internet connection or airplane mode enabled")
        end
    end

  end

  def internet_connected?
    TMReachability.reachabilityForInternetConnection.isReachable
  end

  def edit_group
    if @group_name.text.present?
      handle_valid_submission
    else
      App.alert("Please enter a group name")
    end
  end

  def handle_valid_submission
    
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

    process_edit_group @group_name.text, @group_owner.text, @group_description.text, privacy, members_events
  end

  def process_edit_group(group_name, group_owner, group_description, privacy, members_events)
    auth_token = MotionKeychain.get('auth_token')
    group_id = NSUserDefaults.standardUserDefaults["group-id"]

    GroupEditService.new(self, {group_name: group_name, group_owner: group_owner, group_description: group_description, privacy: privacy, members_events: members_events, auth_token: auth_token, group_id: group_id }).process
  end

  def handle_group_edit_failed
    App.alert('Group edit failed, please try again')
  end

  def handle_group_edit_successful
    new_controller = GroupsController.alloc.initWithStyle(UITableViewStylePlain)
    self.navigationController.pushViewController(new_controller, animated: true)
  end

  def handle_server_error
    App.alert('something went wrong')
  end

  def invite_friends
    new_controller = GroupInviteFriendsController.alloc.initWithNibName(nil, bundle: nil)
    self.navigationController.pushViewController(new_controller, animated: true)
  end

  def invite_members
    new_controller = GroupInviteMembersController.alloc.initWithNibName(nil, bundle: nil)
    self.navigationController.pushViewController(new_controller, animated: true)
  end

  def list_members
    new_controller = GroupListMembersController.alloc.initWithNibName(nil, bundle: nil)
    self.navigationController.pushViewController(new_controller, animated: true)
  end

  def handle_invites_failed
        App.alert("Something went wrong, please try again")
  end

  def handle_invites_successful
      App.alert("Invites sent.")
  end


  def destroy_group_confirmation

    BW::UIAlertView.new({
      buttons: ['Destroy Group', 'Cancel'],
      cancel_button_index: 1
    }) do |alert|
        if alert.clicked_button.cancel?
          #cancelled
        else
          destroy_group
        end
      end.show

  end

  def destroy_group
    auth_token = @auth_token
    group_id = NSUserDefaults.standardUserDefaults["group-id"]
    ref = Firebase.alloc.initWithUrl("https://urvirl.firebaseio.com/chat/room-messages")
    ref.child(NSUserDefaults.standardUserDefaults["group-chat_id"]).clear!

    GroupDestroyService.new(self, { auth_token: auth_token, group_id: group_id }).process
  end

  def handle_groupdestroy_failed
    App.alert("Something went wrong, please try again")
  end

  def handle_groupdestroy_successful
    new_controller = GroupsController.alloc.initWithNibName(nil, bundle: nil)
    self.navigationController.pushViewController(new_controller, animated: true)
    App.alert("Destroyed Group")
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
    up_position = CGRectOffset(self.view.frame, 0, (y)) #put y +40 if using the bottom navigation bar
    if self.view.frame.size.height == self.view.frame.size.height + y
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
    down_position = CGRectOffset(self.view.frame, 0, (y))
    UIView.animateWithDuration(duration,animations: lambda { self.view.setFrame(down_position) },completion: lambda {|finished| }) 
  end

  def resign_keyboard
    #@group_invited.resignFirstResponder
    self.view.endEditing(true)
  end 

  def go_back
    new_controller = GroupMenuController.alloc.initWithNibName(nil, bundle: nil)
    self.navigationController.pushViewController(new_controller, animated: false)
  end
end


