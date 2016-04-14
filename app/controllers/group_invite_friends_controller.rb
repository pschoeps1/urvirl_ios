class GroupInviteFriendsController < UIViewController

  def viewDidLoad
    super
    
    UIApplication.sharedApplication.applicationIconBadgeNumber = 0


    @friends = []
    @group_users = []
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
    titleView.text = "Find Friends"
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
    group_id = NSUserDefaults.standardUserDefaults["group-id"]
    url = "http://mighty-mesa-2159.herokuapp.com/v1/friendships?auth_token=#{auth_token}&group_id=#{group_id}"

    @group_users.clear
    @friends.clear
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

      if json['friends'] == nil
        App.alert("No friends yet, go find some from the main menu!")
      else

         friends = []
         json['friends'].each do |dict|
           friends << dict
          end
          Dispatch::Queue.main.sync { load_friends(friends) }
      end

      if json['group_users'] == nil
         # do nothing
      else

         group_users = []
         json['group_users'].each do |dict|
          group_users << dict
         end

         Dispatch::Queue.main.sync { load_group_users(group_users) }
      end

    end

  end

  def load_friends(friends)
    @friends = friends
    @table.reloadData
  end

  def load_group_users(group_users)
    @group_users = group_users
    @table.reloadData
  end

  def tableView(tableView, numberOfRowsInSection: section)
    @friends.count
  end

  def tableView(tableView, cellForRowAtIndexPath: indexPath)
    @reuseIdentifier ||= "CELL_IDENTIFIER"

    cell = tableView.dequeueReusableCellWithIdentifier(@reuseIdentifier)
  
    if !cell
      cell ||= UITableViewCell.alloc.initWithStyle( UITableViewCellStyleValue1, reuseIdentifier:@reuseIdentifier)
    end

    cell.textLabel.text = @friends[indexPath.row]['username']

    @group_users.each do |user| 
      if user['id'] == @friends[indexPath.row]['id']
        cell.detailTextLabel.text = "already in group"
      end
    end



    cell

  end

  def tableView(tableView, didSelectRowAtIndexPath:indexPath)
    tableView.deselectRowAtIndexPath(indexPath, animated: true)

    group_user_ids = []
    @group_users.each do |f| 
      i = f['id'].to_i
      group_user_ids << i
    end

   
      if group_user_ids.include? @friends[indexPath.row]['id']
        BW::UIAlertView.new({
          buttons: ['Remove from group', 'Cancel'],
          cancel_button_index: 1
          }) do |alert|
            if alert.clicked_button.cancel?
              #cancelled
            else
              followed_id = NSUserDefaults.standardUserDefaults["group-id"]
              auth_token = @auth_token
              follower_id = @friends[indexPath.row]['id']
              
              if internet_connected?
                 GroupLeaveAdminService.new(self, {auth_token: auth_token, followed_id: followed_id, follower_id: follower_id}).process
              else
                  App.alert("Poor internet connection or airplane mode enabled")
              end
            end
          end.show
      else

        BW::UIAlertView.new({
          buttons: ['Add to group', 'Cancel'],
          cancel_button_index: 1
          }) do |alert|
            if alert.clicked_button.cancel?
              #cancelled
            else
              followed_id = NSUserDefaults.standardUserDefaults["group-id"]
              follower_id = @friends[indexPath.row]['id']
              auth_token = @auth_token
              
              join_url = "http://mighty-mesa-2159.herokuapp.com/v1/relationships/create?followed_id=#{followed_id}&auth_token=#{auth_token}&follower_id=#{follower_id}"
              if internet_connected?
                json = JSONService.parse_from_url(join_url)
              else
                App.alert("Airplane mode enabled or poor internet connection")
              end
              
              if json['success'] == true
                 App.alert("Member Added")
                 #friend_ids << json['new_friend']['friend_id'].to_i
                 @group_users << json['new_group_user']
              else
                App.alert("An error occurred, please try again")
               @table.reloadData
              end
              @table.reloadData
            end
          end.show

      end

  end

  def handle_groupleave_failed
    App.alert('Something went wrong, please try again.')
  end

  def handle_groupleave_successful
    new_controller = AdminSettingsController.alloc.initWithNibName(nil, bundle: nil)
    new_controller.blocked_users = @blocked_users
    self.navigationController.pushViewController(new_controller, animated: true)
    App.alert('Member Removed')
    @table.reloadData
  end

  
end


