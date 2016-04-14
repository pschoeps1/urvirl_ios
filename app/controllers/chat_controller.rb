class ChatController < JSQMessagesViewController


alias :'super_collectionView:cellForItemAtIndexPath' :'collectionView:cellForItemAtIndexPath'


  attr_accessor :group, :blocked_users, :messages, :incomingBubbleImageView, :outgoingBubbleImageView
  def viewDidLoad
    @transferManager = AWSS3TransferManager.defaultS3TransferManager

    nav_id = NSUserDefaults.standardUserDefaults["nav-id"]
    if nav_id
      NSUserDefaults.standardUserDefaults["nav-id"] = ""
    end

    self.messages = NSMutableArray.alloc.init
    @message_ids = []
    @email = MotionKeychain.get('email')
    @auth_token = MotionKeychain.get('auth_token')
    @user = NSUserDefaults.standardUserDefaults["id"].to_s
    @name = MotionKeychain.get('name')
    @keyboard_height = 0
    super

    color = determine_color(NSUserDefaults.standardUserDefaults["group-color"])
    urvirl_blue = UIColor.colorWithRed(0, green:0.639, blue:0.878, alpha:1)
    urvirl_purple =  UIColor.colorWithRed(0.306, green:0, blue:0.557, alpha:1)





    #jsqmessages stuff
    automaticallyScrollsToMostRecentMessage = false
    #collectionView.collectionViewLayout.springinessEnabled = true
    #self.showLoadEarlierMessagesHeader = true
    self.inputToolbar.contentView.textView.pasteDelegate = self

    self.senderId = @user
    self.senderDisplayName = @name


    bubble_factory = JSQMessagesBubbleImageFactory.alloc.init
    self.outgoingBubbleImageView = bubble_factory.outgoingMessagesBubbleImageWithColor(color)
    self.incomingBubbleImageView = bubble_factory.incomingMessagesBubbleImageWithColor(UIColor.jsq_messageBubbleLightGrayColor)
    self.collectionView.collectionViewLayout.incomingAvatarViewSize = CGSizeZero
    self.collectionView.collectionViewLayout.outgoingAvatarViewSize = CGSizeZero
    #end jsqmessages stuff

    #navbar styling/definition
    titleView = UILabel.alloc.initWithFrame(CGRectZero)
    titleView.backgroundColor = UIColor.clearColor
    titleView.font = UIFont.boldSystemFontOfSize(20.0)
    titleView.shadowColor = UIColor.colorWithWhite(0.0,alpha:0.5)
    titleView.textColor = UIColor.whiteColor
    self.navigationItem.titleView = titleView
    titleView.text = NSUserDefaults.standardUserDefaults["group-name"]
    titleView.sizeToFit

    self.navigationController.navigationBar.tintColor = UIColor.whiteColor
    
    blue = UIColor.colorWithRed(0.00,green:0.64,blue:0.88,alpha:1.0)
    red = UIColor.colorWithRed(0.937,green:0.259,blue:0.435,alpha:1.0)

    chat_id = NSUserDefaults.standardUserDefaults["group-chat_id"]
    @ref = Firebase.alloc.initWithUrl("https://urvirl.firebaseio.com/chat/room-messages/#{chat_id}")
   
    if @blocked_users
        read_data
    else
      get_blocked_users
    end
  end

  def viewWillAppear(animated)
    super 

    rightButton = UIBarButtonItem.alloc.initWithTitle("Menu",style:UIBarButtonItemStyleDone,target: self,action:'push_menu')
    self.navigationItem.rightBarButtonItem = rightButton

    self.navigationItem.setHidesBackButton(true)
    leftButton = UIBarButtonItem.alloc.initWithTitle("Back",style:UIBarButtonItemStyleDone,target: self,action:'go_back')
    self.navigationItem.leftBarButtonItem = leftButton
  end


  def viewDidAppear(animated)
    super
    self.collectionView.collectionViewLayout.springinessEnabled = false
  end

  def didPressAccessoryButton(sender)
    showImagePicker
  end

  def internet_connected?
    TMReachability.reachabilityForInternetConnection.isReachable
  end

  def read_data

      email =  @email
      token = @auth_token 

    if internet_connected?
      SVProgressHUD.showWithMaskType(SVProgressHUDMaskTypeClear)
      @messages = []



      ref = @ref

      ref.query(order_by: 'timestamp', last: 100, on: :added) do |snapshot| 

         message = snapshot.value["message"] 
         userId = snapshot.value["userId"] 
         name = snapshot.value["name"]
         date = snapshot.value["timestamp"]
         messageId = snapshot.value["messageId"]
         media = snapshot.value["type"]
         key = snapshot.value["key"]

         date_int = date.to_i
         date = NSDate.dateWithTimeIntervalSince1970(date_int/1000)

        if media == "media"
          mediaItem = JSQPhotoMediaItem.alloc.initWithImage(nil)
          new_message = JSQMessage.alloc.initWithSenderId(userId.to_s, senderDisplayName:name, date: date, media: mediaItem)

            group_id = NSUserDefaults.standardUserDefaults["group-id"]

            #define a directory to temporarily store the photo
            downloadingFilePath = NSTemporaryDirectory().stringByAppendingPathComponent("downloaded-myImage.png")
            downloadingFileURL = NSURL.fileURLWithPath(downloadingFilePath)

            #create new download request through the Amazon S3 SDK
            downloadRequest = AWSS3TransferManagerDownloadRequest.new

            downloadRequest.bucket = "ios-photos-urvirl"
            downloadRequest.key = "#{key}"
            downloadRequest.downloadingFileURL = downloadingFileURL

            #Initiate transfer
            @transferManager.download(downloadRequest).continueWithExecutor(AWSExecutor.mainThreadExecutor, withBlock: lambda do |task|

              if task.error
                App.alert("Something went wrong")
              else
                mediaItem.image = UIImage.imageWithContentsOfFile(downloadingFilePath)
                self.collectionView.reloadData
              end
            
            end)
    
        else
         new_message = JSQMessage.alloc.initWithSenderId(userId.to_s, senderDisplayName: name, date: date, text: message)

        end

         self.messages.addObject(new_message)
         self.collectionView.reloadData
         self.finishReceivingMessage
         self.scrollToBottomAnimated(false)
         SVProgressHUD.dismiss
      end




    else 
      App.alert("Poor internet connection or airplane mode enabled")
    end


  end



 def collectionView(collectionView, messageDataForItemAtIndexPath:indexPath)
    return self.messages[indexPath.item]
  end




  def collectionView(collectionView, messageBubbleImageDataForItemAtIndexPath:indexPath)

    message = self.messages[indexPath.item]

    if message.senderId == @user
      self.outgoingBubbleImageView
    else
      self.incomingBubbleImageView
    end

  end





  def collectionView(collectionView, avatarImageDataForItemAtIndexPath:indexPath)
    return nil 
  end







  def collectionView(collectionView,  attributedTextForCellTopLabelAtIndexPath:indexPath)

    if (indexPath.item % 3 == 0)
      message = self.messages[indexPath.item]
      return JSQMessagesTimestampFormatter.sharedFormatter.attributedTimestampForDate(message.date)
    end

    return nil
  end



  def collectionView(collectionView,  attributedTextForMessageBubbleTopLabelAtIndexPath:indexPath)

    message = self.messages[indexPath.item]

    # Don't specify attributes to use the defaults.
    return NSAttributedString.alloc.initWithString(message.senderDisplayName)
  end


  def collectionView(collectionView,  attributedTextForCellBottomLabelAtIndexPath:indexPath)
    return nil
  end


  def collectionView(collectionView,  numberOfItemsInSection:section)
    if self.messages
      self.messages.count
    else
      0
    end
  end





  def collectionView(collectionView, cellForItemAtIndexPath:indexPath)

    cell = super_collectionView(collectionView, cellForItemAtIndexPath:indexPath)
    message = self.messages[indexPath.item]

    if @blocked_users.include? message.senderId.to_i
      cell.textView.text = "User Blocked"
    end

    unless message.isMediaMessage
      if message.senderId == @user
        cell.textView.textColor = UIColor.whiteColor
      else
        cell.textView.textColor = UIColor.blackColor
      end
    end





    return cell
  end


  def collectionView(collectionView,  layout:collectionViewLayout, heightForCellTopLabelAtIndexPath:indexPath)
    60
  end



  def collectionView(collectionView, layout:collectionViewLayout, heightForMessageBubbleTopLabelAtIndexPath:indexPath)

    # iOS7-style sender name labels
    currentMessage = self.messages[indexPath.item]
    if currentMessage.senderId == self.senderId
      return 0
    end

    if (indexPath.item - 1 >= 0)
      previousMessage = self.messages[indexPath.item - 1]
      if previousMessage.senderId == currentMessage.senderId
        return 0
      end
    end

    return 20
  end


  def collectionView(collectionView, layout:collectionViewLayout, heightForCellBottomLabelAtIndexPath:indexPath)
    return 0
  end


  def collectionView(collectionView,  header:headerView, didTapLoadEarlierMessagesButton:sender)
    #fn
  end






  def collectionView(collectionView, didTapMessageBubbleAtIndexPath:indexPath)

      message = self.messages[indexPath.item]

      if message.isMediaMessage
       mediaItem = message.media.image
       if mediaItem != nil
         photos = IDMPhoto.photosWithImages([mediaItem])
         browser = IDMPhotoBrowser.alloc.initWithPhotos(photos)
         self.presentViewController(browser, animated: true, completion: nil)
       end


      else

      
        message_user = message.senderId
        user_data = @user.to_i 
        user_blocked = false
        message_id = message.senderId


        if user_data == message_user.to_i
          #do nothing
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
              #do nothing
              elsif alert.clicked_button.index == 1
              flag_user(message, message_user)
              else
                block_user(message_user)
              end
            end.show
          end

        end
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


  #
  def didPressSendButton(button, withMessageText:text, senderId:senderId, senderDisplayName:senderDisplayName, date:date)
   JSQSystemSoundPlayer.jsq_playMessageSentSound

    ref = @ref
    name = @name
    timestamp = (((NSDate.date.timeIntervalSince1970)*1000).round)
    signature = BubbleWrap.create_uuid
    id = @user.to_i
    newobj = ref.push({ name: name, message: text, userId: id, timestamp: timestamp, type: "default" })
    msg = newobj.name
    ref.child(msg).update({ messageId: msg })
    #pushes message to "queue" branch to initiate push notification
    chat_id = NSUserDefaults.standardUserDefaults["group-chat_id"]
    task = Firebase.alloc.initWithUrl("https://urvirl.firebaseio.com/queue/tasks").child(signature).setValue({ name: name, message: text, userId: id, timestamp: timestamp, type: "default", chat_room: chat_id, signature: signature })

    message = JSQMessage.alloc.initWithSenderId(senderId.to_s, senderDisplayName:senderDisplayName, date:date, text:text)

    #self.messages << message

    finishSendingMessageAnimated(true)

  end



  def determine_color(color)
    method =  case color
                when "#00BF6F"
                  ui_color = UIColor.colorWithRed(0, green:0.749, blue:0.435, alpha:1)
                when "#4E008E" #purple
                  ui_color = UIColor.colorWithRed(0.306, green:0, blue:0.557, alpha:1)
                when "#FF8674" #pink
                  ui_color = UIColor.colorWithRed(1, green:0.525, blue:0.455, alpha:1)
                when "#EF426F"
                  ui_color = UIColor.colorWithRed(0.937, green:0.259, blue:0.435, alpha:1)
                when "#00A3E0"
                  ui_color = UIColor.colorWithRed(0, green:0.639, blue:0.878, alpha:1)
                when "#97D700;" #light green
                  ui_color = UIColor.colorWithRed(0.592, green:0.843, blue:0, alpha:1)
                when "#97D700" #light green (I messed up, was saving a semicolon with the group color for a while)
                  ui_color = UIColor.colorWithRed(0.592, green:0.843, blue:0, alpha:1)
                when "#fbd75b"
                  ui_color = UIColor.colorWithRed(0.984, green:0.843, blue:0.357, alpha:1)
                when nil 
                  ui_color = UIColor.colorWithRed(0.306, green:0, blue:0.557, alpha:1)
              end
    ui_color
  end

  def push_menu
    new_controller = GroupMenuController.alloc.initWithNibName(nil, bundle: nil)
    self.navigationController.pushViewController(new_controller, animated: true)
  end

  def get_blocked_users
    user_data = NSUserDefaults.standardUserDefaults["id"]
    auth_token = MotionKeychain.get('auth_token')

    url = "http://mighty-mesa-2159.herokuapp.com/v1/users/#{user_data}/dashboard?auth_token=#{auth_token}"


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

  def go_back
    new_controller = GroupsController.alloc.initWithNibName(nil, bundle: nil)
    new_controller.group_id = nil
    self.navigationController.pushViewController(new_controller, animated: false)
  end

  def load_blocked_users(users)
    @blocked_users = users
    read_data
  end



#three actions below open UIImagePicker, download selected image to a local file directory, and then upload that image to aws and then to firebase
  def showImagePicker
    UIImagePickerController.new.tap do |picker|
      picker.delegate = self
      self.presentModalViewController(picker, animated:true)
    end
  end

  def imagePickerController(picker, didFinishPickingMediaWithInfo: info)
    image = info.objectForKey(UIImagePickerControllerOriginalImage)
    #uiImage = UIImageJPEGRepresentation(image, 1.0)
    path = NSTemporaryDirectory().stringByAppendingPathComponent("image.png")
    imageData = UIImagePNGRepresentation(image)
    imageData.writeToFile(path, atomically: true)
    url = NSURL.alloc.initFileURLWithPath(path)
    picker.dismissModalViewControllerAnimated(true)
    processDispatchUpload(url)

    #add image to collection temporarily
    date = (((NSDate.date.timeIntervalSince1970)*1000).round)
    mediaItem = JSQPhotoMediaItem.alloc.initWithImage(image)
    new_message = JSQMessage.alloc.initWithSenderId(@user.to_s, senderDisplayName:@name, date: date, media: mediaItem)
    self.collectionView.reloadData




  end



  def processDispatchUpload(imageData)
    group_id = NSUserDefaults.standardUserDefaults["group-id"]
    key = "#{@user}" + "-" + "#{group_id}" + "-" + "#{BubbleWrap.create_uuid}"

    UIApplication.sharedApplication.setNetworkActivityIndicatorVisible(true)
      uploadRequest = AWSS3TransferManagerUploadRequest.new
      uploadRequest.bucket = "ios-photos-urvirl"
      uploadRequest.key = "#{key}"
      uploadRequest.body = imageData
      uploadRequest.contentType = "image/png"
      uploadRequest.ACL = AWSS3ObjectCannedACLPublicRead

      @transferManager.upload(uploadRequest).continueWithExecutor(AWSExecutor.mainThreadExecutor, withBlock: lambda do |task|
          if task.error
              App.alert("Something went wrong.")
          else
              firebaseUrlKey = key
              uploadFirebaseImage(firebaseUrlKey)
          end
      end)


  
  end

  def uploadFirebaseImage(key)
    ref = @ref
    name = @name
    timestamp = (((NSDate.date.timeIntervalSince1970)*1000).round)
    signature = BubbleWrap.create_uuid
    id = @user.to_i
    newobj = ref.push({ name: name, message: "", userId: id, timestamp: timestamp, type: "media", key: key })
    msg = newobj.name
    ref.child(msg).update({ messageId: msg })
    #pushes message to "queue" branch to initiate push notification
    chat_id = NSUserDefaults.standardUserDefaults["group-chat_id"]
    task = Firebase.alloc.initWithUrl("https://urvirl.firebaseio.com/queue/tasks").child(signature).setValue({ name: name, message: nil, userId: id, timestamp: timestamp, type: "default", chat_room: chat_id, signature: signature })

    


    #self.collectionView.reloadData
  end

  def downloadImage(key)
    group_id = NSUserDefaults.standardUserDefaults["group-id"]

    downloadingFilePath = NSTemporaryDirectory().stringByAppendingPathComponent("downloaded-myImage.png")
    downloadingFileURL = NSURL.fileURLWithPath(downloadingFilePath)


    downloadRequest = AWSS3TransferManagerDownloadRequest.new

    downloadRequest.bucket = "urvirl2015"
    downloadRequest.key = "ios_images/#{group_id}/#{key}"
    downloadRequest.downloadingFileURL = downloadingFileURL

    @transferManager.download(downloadRequest, continueWithExecutor: AWSExecutor.mainThreadExecutor)
    downloadingFilePath
  end
    
end