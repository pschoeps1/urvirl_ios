class FindGroupsController < UIViewController
  def viewDidLoad
    super
    
    UIApplication.sharedApplication.applicationIconBadgeNumber = 0
    self.navigationItem.setHidesBackButton(true)
    leftButton = UIBarButtonItem.alloc.initWithTitle("Back",style:UIBarButtonItemStyleDone,target: self,action:'go_back')
    self.navigationItem.leftBarButtonItem = leftButton


    @data = []
    @joined_groups = []
    @email = MotionKeychain.get('email')
    @auth_token = MotionKeychain.get('auth_token')
    @user = NSUserDefaults.standardUserDefaults["id"]

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


    searchBar.text = ' '
    searchBarSearchButtonClicked(searchBar)

    

    titleView = UILabel.alloc.initWithFrame(CGRectZero)
    titleView.backgroundColor = UIColor.clearColor
    titleView.font = UIFont.boldSystemFontOfSize(20.0)
    titleView.shadowColor = UIColor.colorWithWhite(0.0,alpha:0.5)
    titleView.textColor = UIColor.whiteColor
    self.navigationItem.titleView = titleView
    titleView.text = "Find Groups"
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
    url = "http://mighty-mesa-2159.herokuapp.com/v1/groups?search=#{query}&user_id=#{user}"

    if internet_connected?

      @data.clear
      @joined_groups.clear
      Dispatch::Queue.concurrent.async do 
        json = nil
        begin
            json = JSONService.parse_from_url(url)
        rescue RuntimeError => e
          presentError e.message
        end

        new_groups = []
        json['groups'].each do |dict|
         new_groups << dict
        end

        joined_groups = []
        json['joined'].each do |dict|
          joined_groups << dict
        end

        Dispatch::Queue.main.sync { load_groups(new_groups) }
        Dispatch::Queue.main.sync { load_joined_groups(joined_groups) }
      end
    else
        App.alert("Poor internet connection or airplane mode enabled")
    end

    searchBar.resignFirstResponder
  end

  def load_groups(new_groups)
    @data = new_groups
    @table.reloadData
    if @data.length == 0
      App.alert("No results found")
    end
  end

  def load_joined_groups(joined_groups)
    @joined_groups = joined_groups
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

    cell.textLabel.text = @data[indexPath.row]['name']


    if @joined_groups.include? @data[indexPath.row]['id']
      cell.detailTextLabel.text = "joined"
    end


    cell

  end

  def tableView(tableView, didSelectRowAtIndexPath:indexPath)
    tableView.deselectRowAtIndexPath(indexPath, animated: true)

    if @joined_groups.include? @data[indexPath.row]['id']
      App.alert("You have already joined this group, access it from the dashboard")
    else
      BW::UIAlertView.new({
          buttons: ['Join Group', 'Cancel'],
          cancel_button_index: 1
          }) do |alert|
            if alert.clicked_button.cancel?
              #cancelled
            else
              if internet_connected?
                followed_id = @data[indexPath.row]['id']
                auth_token = @auth_token
                join_url = "http://mighty-mesa-2159.herokuapp.com/v1/relationships/create?followed_id=#{followed_id}&auth_token=#{auth_token}"
                json = JSONService.parse_from_url(join_url)
                handle_response(json)
                @joined_groups << followed_id
                @table.reloadData
              else
                App.alert("Airplane mode enabled or poor internet connection")
              end
            end
          end.show
    end

  end

  def handle_response(json)
    if json['success'] == true
      App.alert("Group joined")
    else
      App.alert("An error occurred, please try again")
      @table.reloadData
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

