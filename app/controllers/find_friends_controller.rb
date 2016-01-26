class FindFriendsController < UIViewController
  def viewDidLoad
    super
    
    UIApplication.sharedApplication.applicationIconBadgeNumber = 0
    self.navigationItem.setHidesBackButton(true)
    leftButton = UIBarButtonItem.alloc.initWithTitle("Back",style:UIBarButtonItemStyleDone,target: self,action:'go_back')
    self.navigationItem.leftBarButtonItem = leftButton


    @data = []
    @friends = []
    @email = MotionKeychain.get('email')
    @auth_token = MotionKeychain.get('auth_token')
    @user = NSUserDefaults.standardUserDefaults["id"]

    self.view.frame = [[0, 0],
                   [self.view.frame.size.width, self.view.bounds.size.height - 60]]

    table_frame = [[0, 0],
                   [self.view.frame.size.width, self.view.bounds.size.height]]
    @table = UITableView.alloc.initWithFrame(table_frame)

    @table.delegate = @table.dataSource = self
    self.view.addSubview @table
    @table.dataSource = self


    search_frame = [[0, 0],
                   [self.view.frame.size.width, 0]]
    searchBar = UISearchBar.alloc.initWithFrame(search_frame)
    searchBar.delegate = self;
    searchBar.showsCancelButton = true;
    searchBar.sizeToFit
    @table.tableHeaderView = searchBar


    searchBar.text = ''
    searchBarSearchButtonClicked(searchBar)

    

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

  end

  def internet_connected?
    TMReachability.reachabilityForInternetConnection.isReachable
  end

  def searchBarSearchButtonClicked(searchBar)
    query = searchBar.text.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)
    user = @user
    url = "http://mighty-mesa-2159.herokuapp.com/v1/users?search=#{query}&user_id=#{user}"

    if internet_connected?

      @data.clear
      @friends.clear
      Dispatch::Queue.concurrent.async do 
        json = nil
        begin
          json = JSONService.parse_from_url(url)
        rescue RuntimeError => e
          presentError e.message
        end

        new_users = []
        json['users'].each do |dict|
         new_users << dict
        end

        friends = []
        json['friends'].each do |dict|
          friends << dict
        end

        Dispatch::Queue.main.sync { load_users(new_users) }
        Dispatch::Queue.main.sync { load_friends(friends) }
      end
    else
      App.alert("Poor internet connection or airplane mode enabled")
    end

    searchBar.resignFirstResponder
  end

  def load_users(new_users)
    @data = new_users
    @table.reloadData
    if @data.length == 0
      App.alert("No results found")
    end
  end

  def load_friends(friends)
    @friends = friends
    @table.reloadData
  end

  def tableView(tableView, numberOfRowsInSection: section)
    @data.count
  end

  def tableView(tableView, cellForRowAtIndexPath: indexPath)
    @reuseIdentifier ||= "CELL_IDENTIFIER"

    cell = tableView.dequeueReusableCellWithIdentifier(@reuseIdentifier)
  
    if !cell
      cell ||= UITableViewCell.alloc.initWithStyle( UITableViewCellStyleValue1, reuseIdentifier:@reuseIdentifier)
    end

    cell.textLabel.text = @data[indexPath.row]['username']

    @friends.each do |friend|
      if friend["friend_id"] == @data[indexPath.row]['id']
        cell.detailTextLabel.text = friend['status']
      end
    end



    cell

  end

  def tableView(tableView, didSelectRowAtIndexPath:indexPath)
    tableView.deselectRowAtIndexPath(indexPath, animated: true)

    friend_ids = []
    @friends.each do |f|
      i = f['friend_id'].to_i
      friend_ids << i
    end

   
      if friend_ids.include? @data[indexPath.row]['id']
        App.alert("You are already friends, or the request is pending")
      else
        BW::UIAlertView.new({
          buttons: ['Send Request', 'Cancel'],
          cancel_button_index: 1
          }) do |alert|
            if alert.clicked_button.cancel?
              #cancelled
            else
              if internet_connected?
                friend_id = @data[indexPath.row]['id']
                auth_token = @auth_token
              
                join_url = "http://mighty-mesa-2159.herokuapp.com/v1/friendships/create?friend_id=#{friend_id}&auth_token=#{auth_token}"
                json = JSONService.parse_from_url(join_url)
              
                if json['success'] == true
                  App.alert("Request Sent")
                  #friend_ids << json['new_friend']['friend_id'].to_i
                  @friends << json['new_friend']
                else
                  App.alert("An error occurred, please try again")
                 @table.reloadData
                end
                @table.reloadData
              else
                App.alert("Poor internet connection or airplane mode enabled")
              end
            end
          end.show
      end

  end

  def searchBarCancelButtonClicked(searchBar)
    searchBar.resignFirstResponder
  end
  
  def go_back
    new_controller = GroupsController.alloc.initWithNibName(nil, bundle: nil)
    self.navigationController.pushViewController(new_controller, animated: true)
  end


end

