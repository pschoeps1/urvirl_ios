class InboxController < UIViewController

  def viewDidLoad
    super
    
    UIApplication.sharedApplication.applicationIconBadgeNumber = 0


    @pending_friends = []
    @email = MotionKeychain.get('email')
    @auth_token = MotionKeychain.get('auth_token')
    @user = NSUserDefaults.standardUserDefaults["id"]

    table_frame = [[0, 0],
                   [self.view.frame.size.width, self.view.bounds.size.height]]
    @table = UITableView.alloc.initWithFrame(table_frame)

    @table.delegate = @table.dataSource = self
    self.view.addSubview @table
    @table.dataSource = self
    

    titleView = UILabel.alloc.initWithFrame(CGRectZero)
    titleView.backgroundColor = UIColor.clearColor
    titleView.font = UIFont.boldSystemFontOfSize(20.0)
    titleView.shadowColor = UIColor.colorWithWhite(0.0,alpha:0.5)
    titleView.textColor = UIColor.whiteColor
    self.navigationItem.titleView = titleView
    titleView.text = "Inbox"
    titleView.sizeToFit

    self.navigationController.navigationBar.tintColor = UIColor.whiteColor

    rmq.stylesheet = MainStylesheet
    rmq(self.view).apply_style :root_view

    get_friends

  end

  def internet_connected?
    TMReachability.reachabilityForInternetConnection.isReachable
  end

  def get_friends
    auth_token = @auth_token
    user_id = @user
    url = "http://mighty-mesa-2159.herokuapp.com/v1/users/#{user_id}/inbox?auth_token=#{auth_token}"

    @pending_friends.clear
    Dispatch::Queue.concurrent.async do 
      json = nil
      begin
        if internet_connected?
          json = JSONService.parse_from_url(url)
        else
          App.alert("Poor internet connection or airplane mode enabled")
        end
      rescue RuntimeError => e
        presentError e.message
      end

      if json['pending_friends'] == nil
        App.alert("Inbox Empty")
      else

         pending_friends = []
         json['pending_friends'].each do |dict|
           pending_friends << dict
          end
          Dispatch::Queue.main.sync { load_pending_friends(pending_friends) }
      end

    end

  end

  def load_pending_friends(pending_friends)
    @pending_friends = pending_friends
    @table.reloadData
  end

  def tableView(tableView, numberOfRowsInSection: section)
    @pending_friends.count
  end

  def tableView(tableView, cellForRowAtIndexPath: indexPath)
    @reuseIdentifier ||= "CELL_IDENTIFIER"

    cell = tableView.dequeueReusableCellWithIdentifier(@reuseIdentifier)
  
    if !cell
      cell ||= UITableViewCell.alloc.initWithStyle( UITableViewCellStyleValue1, reuseIdentifier:@reuseIdentifier)
    end

    cell.textLabel.text = @pending_friends[indexPath.row]['username']

    cell

  end

  def tableView(tableView, didSelectRowAtIndexPath:indexPath)
    tableView.deselectRowAtIndexPath(indexPath, animated: true)

        BW::UIAlertView.new({
          buttons: ['Accept', 'Decline', 'Cancel'],
          cancel_button_index: 2
          }) do |alert|
            if alert.clicked_button.cancel?
              #cancelled
            elsif alert.clicked_button.index == 1
              auth_token = @auth_token
              friend_id = @pending_friends[indexPath.row]['id']
              id = @user
              
              if internet_connected?
                 FriendDeclineService.new(self, {auth_token: auth_token, friend_id: friend_id, id: id}).process
              else
                  App.alert("Poor internet connection or airplane mode enabled")
              end
            else
              auth_token = @auth_token
              friend_id = @pending_friends[indexPath.row]['id']
              id = @user
              
              if internet_connected?
                 FriendAcceptService.new(self, {auth_token: auth_token, friend_id: friend_id, id: id}).process
              else
                  App.alert("Poor internet connection or airplane mode enabled")
              end
            end
          end.show

  end

  def handle_friend_decline_failed
    App.alert('Something went wrong, please try again.')
  end

  def handle_friend_accept_failed
    App.alert('Something went wrong, please try again.')
  end

  def handle_friend_decline_successful
    #new_controller = AdminSettingsController.alloc.initWithNibName(nil, bundle: nil)
    #new_controller.group = @group
    #new_controller.blocked_users = @blocked_users
    #self.navigationController.pushViewController(new_controller, animated: true)
    App.alert('Friendship Declined')
    get_friends
  end

  def handle_friend_accept_successful
    App.alert('Friendship Accepted')
    get_friends
  end

  
end


