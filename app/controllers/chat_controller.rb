class ChatController < UIViewController
  attr_accessor :group, :blocked_users
  def viewDidLoad
    @data = NSMutableArray.alloc.init
    @keys = @data.map { |r| r.name }
    @email = MotionKeychain.get('email')
    @auth_token = MotionKeychain.get('auth_token')
    @user = NSUserDefaults.standardUserDefaults["id"]
    @name = MotionKeychain.get('name')
    @keyboard_height = 0
    super

    self.navigationItem.setHidesBackButton(true)
    leftButton = UIBarButtonItem.alloc.initWithTitle("Back",style:UIBarButtonItemStyleDone,target: self,action:'go_back')
    self.navigationItem.leftBarButtonItem = leftButton

    #rightButton = UIBarButtonItem.alloc.initWithTitle("Settings",style:UIBarButtonItemStyleDone,target: self,action:'push_settings')
    #self.navigationItem.rightBarButtonItem = rightButton

    rightButton = UIBarButtonItem.alloc.initWithTitle("Menu",style:UIBarButtonItemStyleDone,target: self,action:'push_menu')
    self.navigationItem.rightBarButtonItem = rightButton

    self.navigationItem.rightBarButtonItem.setTintColor(UIColor.whiteColor)

    titleView = UILabel.alloc.initWithFrame(CGRectZero)
    titleView.backgroundColor = UIColor.clearColor
    titleView.font = UIFont.boldSystemFontOfSize(20.0)
    titleView.shadowColor = UIColor.colorWithWhite(0.0,alpha:0.5)
    titleView.textColor = UIColor.whiteColor
    self.navigationItem.titleView = titleView
    titleView.text = NSUserDefaults.standardUserDefaults["group-name"]
    titleView.sizeToFit

    self.navigationController.navigationBar.tintColor = UIColor.whiteColor
    
    #weird frame sizes are due to viewdeck controller adding extra padding to background menu
    table_frame = [[0, 0],
                   [self.view.frame.size.width, self.view.bounds.size.height - 105]]
    @table = UITableView.alloc.initWithFrame(table_frame)

    @table.delegate = @table.dataSource = self
    self.view.addSubview @table
    @table.dataSource = self

    blue = UIColor.colorWithRed(0.00,green:0.64,blue:0.88,alpha:1.0)
    red = UIColor.colorWithRed(0.937,green:0.259,blue:0.435,alpha:1.0)

   # @text_field = rmq.append(UITextView, :text_field).get
    #@text_field.frame =  [[40, self.view.frame.size.height - 105], [self.view.frame.size.width - 80, 40]]
    
    text_frame = [[40, self.view.frame.size.height - 105], [self.view.frame.size.width - 80, 40]]
    @text_field = UITextView.alloc.initWithFrame(text_frame)
    #@text_field.enablesReturnKeyAutomatically = true
    #@text_field.textContainerInset = UIEdgeInsetsMake(12, 15, 12, 15)
    @text_field.placeholder = "Send a Message..."
    @text_field.placeholderColor = UIColor.lightGrayColor
    @text_field.contentOffset = CGPointMake(0, -5)
    @text_field.delegate = self
    @text_field.layer.borderWidth = 5
    @text_field.layer.borderColor = UIColor.grayColor
    #@text_field.font = UIFont.fontWithName('tw-cent-bold', size: 32)
    @text_field.setFont(UIFont.systemFontOfSize(15))
    #@text_field.addObserver(self, selector: :textViewDidChange, name: UITextViewTextDidChangeNotification, object: self)
    NSNotificationCenter.defaultCenter.addObserver(self, selector: :textViewDidChange, name: :UITextViewTextDidChangeNotification, object: @text_field)
    self.view.addSubview(@text_field)



    @button = UIButton.buttonWithType(UIButtonTypeRoundedRect)
    @button.frame = CGRectMake((self.view.frame.size.width - 40), (self.view.frame.size.height - 105), 40, 40)
    #@button.setImage(imageFromSystemBarButton:UIBarButtonSystemItemTrash, forState:UIControlStateNormal)

    @button.setBackgroundColor(blue)
  
    @button.setTitle("+",forState:UIControlStateNormal)
    @button.setTitleColor(UIColor.whiteColor, forState:UIControlStateNormal)
    @button.addTarget(self, action: :message_send, forControlEvents: UIControlEventTouchUpInside)
    @button.titleLabel.font = UIFont.systemFontOfSize(16)
    self.view.addSubview(@button)

    @cancel_button = UIButton.buttonWithType(UIButtonTypeRoundedRect)
    @cancel_button.setBackgroundColor(UIColor.whiteColor)
    @cancel_button.frame = CGRectMake(0, (self.view.frame.size.height - 105), 40, 40)
    @cancel_button.setTitle("x",forState:UIControlStateNormal)
    @cancel_button.setTitleColor(red, forState:UIControlStateNormal)
    @cancel_button.addTarget(self, action: :resign_keyboard, forControlEvents: UIControlEventTouchUpInside)
    @cancel_button.titleLabel.font = UIFont.systemFontOfSize(17)
    self.view.addSubview(@cancel_button)

    chat_id = NSUserDefaults.standardUserDefaults["group-chat_id"]
    @ref = Firebase.alloc.initWithUrl("https://urvirl.firebaseio.com/chat/room-messages/#{chat_id}")
    if @blocked_users
      read_data
    else
      get_blocked_users
    end
    register_keyboard_events
  end

  def internet_connected?
    TMReachability.reachabilityForInternetConnection.isReachable
  end

  def read_data
      email =  @email #NSUserDefaults.standardUserDefaults["email"]
      token = @auth_token #NSUserDefaults.standardUserDefaults["auth_token"]

    @data.clear
      
    if internet_connected?
      #SVProgressHUD.showWithMaskType(SVProgressHUDMaskTypeClear)
      ref = @ref
      ref.query(order_by: 'timestamp', last: 100, on: :added) do |snapshot| 
      @data.addObject(snapshot.value)
      #@data.sort! { |x, y| x["timestamp"] <=> y["timestamp"] }
       # @table.reloadData
        #scroll_bottom
      end

      ref.query(order_by: 'timestamp', last: 100, on: :changed) do |snapshot| 
      @data.addObject(snapshot.value)
      #@data.sort! { |x, y| x["timestamp"] <=> y["timestamp"] }
       # @table.reloadData
        #scroll_bottom
      end

      ref.query(order_by: 'timestamp', last: 100, on: :value) do |snapshot| 
        @table.reloadData
        scroll_bottom
      #@data.sort! { |x, y| x["timestamp"] <=> y["timestamp"] }
       # @table.reloadData
        #scroll_bottom
      end

      #ref.on(FEventTypeValue){ |snapshot| 'FDataSnapshot'
      #@table.reloadData
      #scroll_bottom
      
      #}
        
      

     # ref.on(FEventTypeChildChanged) { |snapshot| 'FDataSnapshot'
     # @data.removeLastObject
     # @data.addObject(snapshot.value)
     # @data.sort! { |x, y| x["timestamp"] <=> y["timestamp"] }
     #   @table.reloadData
     #   scroll_bottom
        
     # }

      #ref.on(FEventTypeValue){ |snapshot| 'FDataSnapshot'
      #@table.reloadData
      #scroll_bottom
      
      #}

    else 
      App.alert("Poor internet connection or airplane mode enabled")
    end
    #SVProgressHUD.dismiss
  end

  def message_send
    ref = @ref
    #@name = NSUserDefaults.standardUserDefaults["name"]
    name = @name
    timestamp = (((NSDate.date.timeIntervalSince1970)*1000).round)
    signature = BubbleWrap.create_uuid
    id = @user #NSUserDefaults.standardUserDefaults["id"]
    if @text_field.text.length == 0
      App.alert("Please enter some text")
    else
      newobj = ref.push({ name: name, message: @text_field.text, userId: id, timestamp: timestamp, type: "default" })
      msg = newobj.name
      ref.child(msg).update({ messageId: msg })
      #pushes message to "queue" branch to initiate push notification
      chat_id = NSUserDefaults.standardUserDefaults["group-chat_id"]
      task = Firebase.alloc.initWithUrl("https://urvirl.firebaseio.com/queue/tasks").child(signature).setValue({ name: name, message: @text_field.text, userId: id, timestamp: timestamp, type: "default", chat_room: chat_id, signature: signature })
      @text_field.resignFirstResponder
      @text_field.setText("")
      #@text_field.contentOffset = CGPointMake(0,0)
      @table.reloadData
      @text_field.resignFirstResponder
      original_position = CGRectMake(40, self.view.frame.size.height - 41, self.view.frame.size.width - 80, 40 )
    #CGRectMake ( CGFloat x, CGFloat y, CGFloat width, CGFloat height );
    #[[40, self.view.frame.size.height - 105], [self.view.frame.size.width - 80, 40]]
      UIView.animateWithDuration(0.5 ,animations: lambda { @text_field.setFrame(original_position) },completion: lambda {|finished| }) 
    end
  end

  def resign_keyboard
    @text_field.resignFirstResponder
    true
  end

  def tableView(tableView, numberOfSectionsInTableView: tableView)
    return 1
  end

  def tableView(tableView, numberOfRowsInSection: section)
    @data.count
  end

  def tableView(tableView, heightForRowAtIndexPath: indexPath)
    chatMessage = @data[indexPath.row]['message'].to_s
    size = chatMessage.sizeWithFont(UIFont.systemFontOfSize(18), constrainedToSize:[260.0, 300.0], lineBreakMode:UILineBreakModeWordWrap)
    height = (22 + size.height) # 22 is the content margin
    height
  end

  def tableView(tableView, cellForRowAtIndexPath: indexPath)
    @reuseIdentifier ||= "CELL_IDENTIFIER"

    cell = tableView.dequeueReusableCellWithIdentifier(@reuseIdentifier)
    data = @data[indexPath.row]
    id = @user #NSUserDefaults.standardUserDefaults["id"]
    message_id = data['userId']
    message_user = data['name']
    blue = UIColor.colorWithRed(0.00,green:0.64,blue:0.88,alpha:1.0)

    if cell == nil
      cell ||= UITableViewCell.alloc.initWithStyle( UITableViewCellStyleSubtitle, reuseIdentifier:@reuseIdentifier)
      cell.textLabel.font = UIFont.systemFontOfSize(18)
      cell.textLabel.numberOfLines = 0
    end

    cell.detailTextLabel.text = message_user
    cell.textColor = UIColor.blackColor
    cell.detailTextLabel.textColor = UIColor.blackColor

    if id == message_id.to_i
      cell.textColor = blue
      cell.detailTextLabel.textColor = blue
    end

    if @blocked_users.include? message_id.to_i
      cell.textLabel.text = "User Blocked"
    else
      cell.textLabel.text = data['message']
    end

    return cell
    
  end

  def tableView(tableView, didSelectRowAtIndexPath:indexPath)
   tableView.deselectRowAtIndexPath(indexPath, animated: true)
   message = @data[indexPath.row]['message']
   message_user = @data[indexPath.row]['userId']
   user_data = @user #NSUserDefaults.standardUserDefaults["id"]
   user_blocked = false
   message_id = @data[indexPath.row]['messageId']

   
    if user_data == message_user.to_i
      if message_id
         BW::UIAlertView.new({
          buttons: ['Delete', 'Cancel'],
          cancel_button_index: 1
          }) do |alert|
            if alert.clicked_button.cancel?
              #cancelled
            else
              ref = @ref
              if internet_connected?
                ref.child(message_id).clear!
                @data.removeObject(@data[indexPath.row])
                App.alert('Message Removed')
              else
                App.alert("Poor internet connection or airplane mode enabled")
              end
            end
          end.show
      end
    else
      if @blocked_users.include? message_user.to_i
        BW::UIAlertView.new({
          buttons: ['Unblock User', 'Cancel'],
          cancel_button_index: 1
          }) do |alert|
            if alert.clicked_button.cancel?
             # 'Canceled'
            else
              unblock_user(message_user)
            end
          end.show
      else 
        BW::UIAlertView.new({
        buttons: ['Block User','Flag User', 'Cancel'],
        cancel_button_index: 2
        }) do |alert|
          if alert.clicked_button.cancel?
           # puts 'Canceled'
          elsif alert.clicked_button.index == 1
            flag_user(message, message_user)
          else
            block_user(message_user)
          end
        end.show
      end
    end
  end

  def flag_user(message, user)
      user_id = user
      user_name = @name #NSUserDefaults.standardUserDefaults["name"]
      reporter_id = @user #NSUserDefaults.standardUserDefaults["id"]
      content = message
      auth_token = @auth_token #NSUserDefaults.standardUserDefaults["auth_token"]
      if internet_connected?
        FlagService.new(self, {user_id: user_id, user_name: user_name, reporter_id: reporter_id, content: content, auth_token: auth_token}).process
      else
        App.alert("Poor internet connection or airplane mode enabled")
      end
  end

  def block_user(user)
    if internet_connected?
      BlockUserService.new(self, {blocked_id: user}).process
    else
      App.alert("Poor internet connection or airplane mode enabled")
    end
  end

  def unblock_user(user)
    if internet_connected?
      UnblockUserService.new(self, {blocked_id: user}).process
    else
      App.alert("Poor internet connection or airplane mode enabled")
    end
  end

  def delete_message(message_id)
    ref = @ref
    ref.child(message_id).clear!
    @table.reloadData
    App.alert('Message Removed')
  end

  def handle_submission_failed
    App.alert('Something went wrong, please try again.')
  end

  def handle_submission_successful
    App.alert('Thank You, our support team will review this user.')
  end

  def handle_blocked_user_successful
    App.alert('User has been blocked.')
    new_controller = GroupsController.alloc.initWithNibName(nil, bundle: nil)
    self.navigationController.pushViewController(new_controller, animated: true)
  end

  def handle_unblock_user_successful
    App.alert('User has been unblocked')
    new_controller = GroupsController.alloc.initWithNibName(nil, bundle: nil)
    self.navigationController.pushViewController(new_controller, animated: true)
  end


  def scroll_bottom
    offset = CGPointMake(0, @table.contentSize.height - @table.frame.size.height)
    if @table.contentSize.height > @table.frame.size.height
      @table.setContentOffset(offset, animated:false)
    end
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
    @keyboard_height = keyboard_rect.size.height
    up_position = CGRectOffset(self.view.frame, 0, (y)) #put y +40 if using the bottom navigation bar
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
    down_position = CGRectOffset(self.view.frame, 0, (y))
    UIView.animateWithDuration(duration,animations: lambda { self.view.setFrame(down_position) },completion: lambda {|finished| }) 
  end

  def textViewDidChange
    size = @text_field.text.sizeWithFont(UIFont.systemFontOfSize(17), constrainedToSize:[222.0, 400.0], lineBreakMode:UILineBreakModeWordWrap)
    inset = @text_field.contentInset
    height = size.height #+ inset.top + inset.bottom
    grow_position = CGRectMake(40, self.view.frame.size.height, self.view.frame.size.width - 80, (height * -1) )
    #CGRectMake ( CGFloat x, CGFloat y, CGFloat width, CGFloat height );
    #[[40, self.view.frame.size.height - 105], [self.view.frame.size.width - 80, 40]]
    if size.height > 200 #set max height on animation
      #do nothing
    else
      if size.height > @text_field.frame.size.height 
        UIView.animateWithDuration(1 ,animations: lambda { @text_field.setFrame(grow_position) },completion: lambda {|finished| }) 
      end
    end
  end

  def go_back
    new_controller = GroupsController.alloc.initWithNibName(nil, bundle: nil)
    self.navigationController.pushViewController(new_controller, animated: false)
  end

  def get_blocked_users
    user_data = NSUserDefaults.standardUserDefaults["id"]
    auth_token = MotionKeychain.get('auth_token')

    url = "http://mighty-mesa-2159.herokuapp.com/v1/users/#{user_data}/dashboard?auth_token=#{auth_token}"


    @data.clear
    Dispatch::Queue.concurrent.async do
      begin
        if internet_connected?
          json = JSONService.parse_from_url(url)
        else
          App.alert("Poor internet connection or airplane mode enabled")
        end
      rescue RuntimeError => e
        presentError e.message
      end

      blocked_users = []
      json["blocked_users"].each do |dict|
        blocked_users << dict['blocked_id']
      end
      Dispatch::Queue.main.sync { load_blocked_users(blocked_users) }
    end
  end

  def load_blocked_users(users)
    @blocked_users = users
    read_data
  end

  def push_menu
    new_controller = GroupMenuController.alloc.initWithNibName(nil, bundle: nil)
    self.navigationController.pushViewController(new_controller, animated: true)
  end

end