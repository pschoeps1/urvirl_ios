class GroupsController < UITableViewController
  def viewDidLoad
    super

    self.navigationController.navigationBar.hidden = false
    purple = UIColor.colorWithRed(0.306, green:0, blue:0.557, alpha:1)
    self.navigationController.navigationBar.setBarTintColor(purple)
    self.navigationController.navigationBar.setTranslucent(false)
    
    #leftButton = UIBarButtonItem.alloc.initWithTitle("Log Out",style:UIBarButtonItemStyleDone,target: self,action:'logout')
    #self.navigationItem.leftBarButtonItem = leftButton
    self.navigationItem.setHidesBackButton(true)

    self.navigationItem.rightBarButtonItem = UIBarButtonItem.alloc.initWithTitle(
                                              "Menu",
                                              style: UIBarButtonItemStyleBordered,
                                              target: viewDeckController,
                                              action: 'toggleRightView'
                                            )

    #self.navigationItem.rightBarButtonItem.setTintColor(UIColor.whiteColor)
    self.navigationItem.rightBarButtonItem.setTintColor(UIColor.whiteColor)



    @data = []
    @blocked_users = []
    @email = MotionKeychain.get('email')
    @auth_token = MotionKeychain.get('auth_token')
    @user = NSUserDefaults.standardUserDefaults["id"]

    titleView = UILabel.alloc.initWithFrame(CGRectZero)
    titleView.backgroundColor = UIColor.clearColor
    titleView.font = UIFont.boldSystemFontOfSize(20.0)
    titleView.shadowColor = UIColor.colorWithWhite(0.0,alpha:0.5)
    titleView.textColor = UIColor.whiteColor
    self.navigationItem.titleView = titleView
    titleView.text = "Groups"
    titleView.sizeToFit
  

    rmq.stylesheet = MainStylesheet
    rmq(self.view).apply_style :root_view


    view.dataSource = view.delegate = self
    if internet_connected?
          getGroupData
    else
          App.alert("Poor internet connection or airplane mode enabled")
    end
  end


  def internet_connected?
    TMReachability.reachabilityForInternetConnection.isReachable
  end

  def logout
    #@email = MotionKeychain.get('email')
    email = @email
    #@device_token = MotionKeychain.get('auth_token')
    device_token = @device_token

    BW::UIAlertView.new({
          buttons: ['Log Out', 'Cancel'],
          cancel_button_index: 1
          }) do |alert|
            if alert.clicked_button.cancel?
              #cancelled
            else
              if internet_connected?
                LogoutService.new(self, {email: email, device_token: device_token}).process
              else
                App.alert("Poor internet connection or airplane mode enabled")
              end
            end
          end.show
  end

  def contact
    new_controller = ContactController.alloc.initWithNibName(nil, bundle: nil)
    self.navigationController.pushViewController(new_controller, animated: true)
  end

  def handle_logout
    MotionKeychain.remove('password')
    new_controller = LoginController.alloc.initWithNibName(nil, bundle: nil)
    self.navigationController.pushViewController(new_controller, animated: false)
  end

  def getGroupData
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

      new_groups = []
      blocked_users = []
      json["groups"].each do |dict|
        new_groups << dict #Group.new(dict)
      end

      json["blocked_users"].each do |dict|
        blocked_users << dict['blocked_id']
      end
      Dispatch::Queue.main.sync { load_groups(new_groups) }
      Dispatch::Queue.main.sync { load_blocked_users(blocked_users) }
    end
  end

  def load_groups(groups)
    @data = groups
    view.reloadData
  end

  def load_blocked_users(users)
    @blocked_users = users
  end

  def tableView(tableView, numberOfRowsInSection: section)
    @data.count
  end

  def tableView(tableView, cellForRowAtIndexPath: indexPath)
    @reuseIdentifier ||= "CELL_IDENTIFIER"

    cell = tableView.dequeueReusableCellWithIdentifier(@reuseIdentifier)

    cell ||= UITableViewCell.alloc.initWithStyle( UITableViewCellStyleValue1, reuseIdentifier:@reuseIdentifier)

    cell.textLabel.text = @data[indexPath.row]['name']


    cell

  end

  def tableView(tableView, didSelectRowAtIndexPath:indexPath)
    UIApplication.sharedApplication.applicationIconBadgeNumber = 0
    tableView.deselectRowAtIndexPath(indexPath, animated: true)

    new_controller = ExperimentalChatController.alloc.initWithNibName(nil, bundle: nil)
    new_controller.blocked_users = @blocked_users
    save_group(@data[indexPath.row])


    #controller = ChatController.alloc.initWithNibName(nil, bundle: nil)
   #controller.group = @data[indexPath.row]
   #controller.blocked_users = @blocked_users
    #nav_controller = UINavigationController.alloc.initWithRootViewController(controller)

    #tab_controller = UITabBarController.alloc.initWithNibName(nil, bundle: nil)
    #tab_controller.viewControllers = [nav_controller]

    self.navigationController.pushViewController(new_controller, animated: true)

  end

  def save_group(group)
    NSUserDefaults.standardUserDefaults["group-id"] = group['id']
    NSUserDefaults.standardUserDefaults["group-name"] = group['name']
    NSUserDefaults.standardUserDefaults["group-teacher"] = group['teacher']
    NSUserDefaults.standardUserDefaults["group-chat_id"] = group['chat_id']
    NSUserDefaults.standardUserDefaults["group-user_id"] = group['user_id']
    NSUserDefaults.standardUserDefaults["group-privacy"] = group['privacy']
    NSUserDefaults.standardUserDefaults["group-member_can_edit"] = group['id']
    NSUserDefaults.standardUserDefaults["group-description"] = group['description']
  end


end

