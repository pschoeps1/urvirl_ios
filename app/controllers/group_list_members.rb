class GroupListMembersController < UIViewController
    attr_accessor :group, :blocked_users

  def viewDidLoad
    super
    
    UIApplication.sharedApplication.applicationIconBadgeNumber = 0


    @members = []
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
    titleView.text = "Members"
    titleView.sizeToFit

    self.navigationController.navigationBar.tintColor = UIColor.whiteColor

    rmq.stylesheet = MainStylesheet
    rmq(self.view).apply_style :root_view

    get_members

  end

  def internet_connected?
    TMReachability.reachabilityForInternetConnection.isReachable
  end

  def get_members
    auth_token = @auth_token
    group_id = NSUserDefaults.standardUserDefaults["group-id"]
    url = "http://mighty-mesa-2159.herokuapp.com/v1/groups/#{group_id}/members?auth_token=#{auth_token}"

    @members.clear
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

      members = []
      json['members'].each do |dict|
       members << dict
      end

      Dispatch::Queue.main.sync { load_members(members) }
    end

  end

  def load_members(members)
    @members = members
    @table.reloadData
  end

  def tableView(tableView, numberOfRowsInSection: section)
    @members.count
  end

  def tableView(tableView, cellForRowAtIndexPath: indexPath)
    @reuseIdentifier ||= "CELL_IDENTIFIER"

    cell = tableView.dequeueReusableCellWithIdentifier(@reuseIdentifier)
  
    if !cell
      cell ||= UITableViewCell.alloc.initWithStyle( UITableViewCellStyleValue1, reuseIdentifier:@reuseIdentifier)
    end

    cell.textLabel.text = @members[indexPath.row]['username']

    cell

  end

  def tableView(tableView, didSelectRowAtIndexPath:indexPath)
    tableView.deselectRowAtIndexPath(indexPath, animated: true)

  end

  
end


