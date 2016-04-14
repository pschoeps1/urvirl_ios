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


    #AWS Set up
    credentialsProvider = AWSCognitoCredentialsProvider.alloc.initWithRegionType(AWSRegionUSEast1, identityPoolId: "us-east-1:93025ea4-adea-4e96-9a1b-6e01cd7e34ad")
    configuration = AWSServiceConfiguration.alloc.initWithRegion(AWSRegionUSEast1, credentialsProvider: credentialsProvider)
    AWSServiceManager.defaultServiceManager.defaultServiceConfiguration = configuration




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
    #a bunch of new stuff yayyyy
  end

  def token_to_string(device_token)  
    device_token.description.stringByTrimmingCharactersInSet(NSCharacterSet.characterSetWithCharactersInString("<>")).stringByReplacingOccurrencesOfString(" ", withString: "")
  end 

  def application(application, didFailToRegisterForRemoteNotificationsWithError: error)  
    #failed to register
  end  

  def application(application, didReceiveRemoteNotification: userInfo)
    group_id = userInfo['group_id']
    navController = self.window.rootViewController
    new_controller = GroupsController.alloc.initWithNibName(nil, bundle: nil)
    new_controller.group_id = group_id
    navController.centerController.pushViewController(new_controller, animated: false)
  end
end
