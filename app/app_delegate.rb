class AppDelegate
  #include CDQ
  attr_accessor :window, :centerController

  def application(application, didFinishLaunchingWithOptions:launchOptions)
    #cdq.setup
    #true
    @window = UIWindow.alloc.initWithFrame(UIScreen.mainScreen.bounds)
    #controller = AuthenticationController.alloc.initWithNibName(nil, bundle: nil)
    #@window.rootViewController = UINavigationController.alloc.initWithRootViewController(controller)
    #@window.makeKeyAndVisible

    chat_controller = ChatController.alloc.initWithNibName(nil, bundle: nil)
    contact_controller = ContactController.alloc.initWithNibName(nil, bundle: nil)

    #self.leftController = LeftViewController.alloc.init
    rightController = RightViewController.alloc.init



    self.centerController = UINavigationController.alloc.initWithRootViewController(AuthenticationController.alloc.init)
    deckController = IIViewDeckController.alloc.initWithCenterViewController(self.centerController,
                                                                              rightViewController: rightController
                                                                              
                                                                            )
    deckController.rightSize = 70
    @window.rootViewController = deckController

    @window.makeKeyAndVisible
    
    true

  end

  def applicationDidBecomeActive(application)
    UIApplication.sharedApplication.applicationIconBadgeNumber = 0
  end

  def application(application, didRegisterUserNotificationSettings: notificationSettings)  
    application.registerForRemoteNotifications
  end 

  def application(application, handleActionWithIdentifier: identifier, forRemoteNotification: userInfo, completionHandler: completionHandler)
    data = userInfo.objectForKey("data")
    
  end



  def application(application, didRegisterForRemoteNotificationsWithDeviceToken: device_token)  
    # Save the device token back to the Rails app.
    # The token first needs to be converted to a string before saving
    string = token_to_string(device_token)
    MotionKeychain.set('device_id', string)
  end

  def token_to_string(device_token)  
    device_token.description.stringByTrimmingCharactersInSet(NSCharacterSet.characterSetWithCharactersInString("<>")).stringByReplacingOccurrencesOfString(" ", withString: "")
  end 

  def application(application, didFailToRegisterForRemoteNotificationsWithError: error)  
    NSLog("%@", error.localizedDescription)
  end  
end
