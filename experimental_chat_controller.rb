class ExperimentalChatController < JSQMessagesViewController



#lets make messages look awesome!
#obj c ex https://github.com/jessesquires/JSQMessagesViewController/tree/develop/JSQMessagesDemo
#swift ex with firebase (awesome) https://github.com/firebase/ios-swift-chat-example/tree/master/FireChat-Swift
#everything else http://www.jessesquires.com/introducing-jsqmessagesvc-6-0/


  attr_accessor :group, :blocked_users
  def viewDidLoad





    @messages = NSMutableArray.alloc.init
    @email = MotionKeychain.get('email')
    @auth_token = MotionKeychain.get('auth_token')
    @user = NSUserDefaults.standardUserDefaults["id"]
    @name = MotionKeychain.get('name')
    @keyboard_height = 0
    super



    #jsqmessages stuff
    automaticallyScrollsToMostRecentMessage = true
    collectionView.collectionViewLayout.springinessEnabled = true

    self.senderId = @user 
    self.senderDisplayName = @name
    #outgoingBubbleImageView = JSQMessagesBubbleImageFactory.outgoingMessageBubbleImageViewWithColor(UIColor.jsq_messageBubbleLightGrayColor())
    #incomingBubbleImageView = JSQMessagesBubbleImageFactory.incomingMessageBubbleImageViewWithColor(UIColor.jsq_messageBubbleGreenColor())




    #end jsqmessages stuff


    #self.navigationItem.rightBarButtonItem.setTintColor(UIColor.whiteColor)

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

   # @text_field = rmq.append(UITextView, :text_field).get
    #@text_field.frame =  [[40, self.view.frame.size.height - 105], [self.view.frame.size.width - 80, 40]]



    chat_id = NSUserDefaults.standardUserDefaults["group-chat_id"]
    @ref = Firebase.alloc.initWithUrl("https://urvirl.firebaseio.com/chat/room-messages/#{chat_id}")
   
    read_data
    do_stuff
  end

  def internet_connected?
    TMReachability.reachabilityForInternetConnection.isReachable
  end

  def read_data
      email =  @email
      token = @auth_token 

   
      
    if internet_connected?

      ref = @ref
      ref.query(order_by: 'timestamp', last: 100, on: :value) do |snapshot| 

         message = snapshot.value["message"] 
         userId = snapshot.value["userId"] 
         name = snapshot.value["name"]

         @messages.addObject(JSQMessage.alloc.initWithSenderId(snapshot.value["userId"]), senderDisplayName: snapshot.value["name"], date: NSDate.distantPast, text: snapshot.value["message"])

         

         #message = Message.new(snapshot.value)
         #@messages.addObject(message)
         self.finishReceivingMessage()
         do_stuff

      end

      ref.query(order_by: 'timestamp', last: 100, on: :added) do |snapshot| 

         message = snapshot.value["message"] 
         userId = snapshot.value["userId"] 
         name = snapshot.value["name"]

         new_message = JSQMessage.alloc.initWithSenderId(snapshot.value["userId"], senderDisplayName: snapshot.value["name"], date: NSDate.distantPast, text: snapshot.value["message"])
         puts new_message

         @messages.addObject(new_message)

         

         #message = Message.new(snapshot.value)
         #@messages.addObject(message)
         self.finishReceivingMessage()
         do_stuff

      end



    else 
      App.alert("Poor internet connection or airplane mode enabled")
    end


  end

  def do_stuff
    @messages.each do |message|
      puts message.name
      puts message.userId
      puts "is the above working?"
    end
  end


  def collectionView(collectionView, numberOfItemsInSection: section)
    @messages.count 
  end

  # override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
   #     return messages.count
   # }

  def collectionView(collectionView, messageDataForItemAtIndexPath: indexPath)
    @messages[indexPath.row].text
  end

   #override func collectionView(collectionView: JSQMessagesCollectionView!, messageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageData! {
   #     return messages[indexPath.item]
    #}

  def collectionView(collectionView, bubbleImageViewForItemAtIndexPath: indexPath)
    message = @messages[indexPath.row].text

    UIImageView(image: incomingBubbleImageView.image, highlightedImage: incomingBubbleImageView.highlightedImage)
  end

  #override func collectionView(collectionView: JSQMessagesCollectionView!, bubbleImageViewForItemAtIndexPath indexPath: NSIndexPath!) -> UIImageView! {
   #     let message = messages[indexPath.item]
        
   #     if message.sender() == sender {
    #        return UIImageView(image: outgoingBubbleImageView.image, highlightedImage: outgoingBubbleImageView.highlightedImage)
    #    }
        
   #     return UIImageView(image: incomingBubbleImageView.image, highlightedImage: incomingBubbleImageView.highlightedImage)
    #}

  def collectionView(collectionView, cellForItemAtIndexPath: indexPath)
    cell = super.collectionView(collectionView, cellForItemAtIndexPath: indexPath)
    message = @messages[indexPath.row].text

    attributes = NSForegroundColorAttributeName(cell.textView.textColor, NSUnderlineStyleAttributeName(1))
    
    cell 
  end

   # override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
   #     let cell = super.collectionView(collectionView, cellForItemAtIndexPath: indexPath) as! JSQMessagesCollectionViewCell
        
   #     let message = messages[indexPath.item]
   #     if message.sender() == sender {
    #        cell.textView.textColor = UIColor.blackColor()
   #     } else {
   #         cell.textView.textColor = UIColor.whiteColor()
   #     }
        
   #     let attributes : [NSObject:AnyObject] = [NSForegroundColorAttributeName:cell.textView.textColor, NSUnderlineStyleAttributeName: 1]
   #     cell.textView.linkTextAttributes = attributes
        
   #     //        cell.textView.linkTextAttributes = [NSForegroundColorAttributeName: cell.textView.textColor,
   #     //            NSUnderlineStyleAttributeName: NSUnderlineStyle.StyleSingle]
   #     return cell
   # }
  
  def collectionView(collectionView, attributedTextForMessageBubbleTopLabelAtIndexPath: indexPath)
    message = @messages[indexPath.row].text
    NSAttributedString.alloc.initWithString(@messages[indexPath.row].senderDisplayName)
  end

  # override func collectionView(collectionView: JSQMessagesCollectionView!, attributedTextForMessageBubbleTopLabelAtIndexPath indexPath: NSIndexPath!) -> NSAttributedString! {
  #      let message = messages[indexPath.item];
        
   #     // Sent by me, skip
  #      if message.sender() == sender {
  #          return nil;
  #      }
        
  #      // Same as previous sender, skip
  #      if indexPath.item > 0 {
  #          let previousMessage = messages[indexPath.item - 1];
  #          if previousMessage.sender() == message.sender() {
  #              return nil;
  #          }
  #      }
        
  #      return NSAttributedString(string:message.sender())
  #  }
 
 def collectionView(collectionView, layout: collectionViewLayout, heightForMessageBubbleTopLabelAtIndexPath: indexPath)
  message = @messages[indexPath.row].text

  30
 end

 # override func collectionView(collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForMessageBubbleTopLabelAtIndexPath indexPath: NSIndexPath!) -> CGFloat {
 #       let message = messages[indexPath.item]
        
 #       // Sent by me, skip
 #       if message.sender() == sender {
 #           return CGFloat(0.0);
 #       }
        
 #       // Same as previous sender, skip
 #       if indexPath.item > 0 {
 #           let previousMessage = messages[indexPath.item - 1];
 #           if previousMessage.sender() == message.sender() {
 #               return CGFloat(0.0);
 #           }
 #       }
        
 #       return kJSQMessagesCollectionViewCellLabelHeightDefault
 #   }

  def handle_submission_failed
    App.alert('Something went wrong, please try again.')
  end

  def handle_submission_successful
    App.alert('Thank You, our support team will review this user.')
  end


end

    