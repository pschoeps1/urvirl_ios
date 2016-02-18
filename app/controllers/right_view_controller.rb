class RightViewController < UIViewController
  def viewDidLoad
    super

    @labels = ["Find Groups", "Find Friends", "Contact Us", "Create Group", "My Events", "Inbox", "Log Out"]

    table_frame = [[0, 50],
                   [self.view.frame.size.width, self.view.bounds.size.height - 50]]
    @table = UITableView.alloc.initWithFrame(table_frame)

    @table.delegate = @table.dataSource = self
    self.view.addSubview @table
    @table.dataSource = self


    #@table.separatorStyle = UITableViewCellSeparatorStyleNone
    self.view.backgroundColor = UIColor.whiteColor
    @table.backgroundColor = UIColor.whiteColor

    #Need to set this dynamically to handle the first cell being larger then the rest
    @table.rowHeight = 30
    @table.dataSource = self
  end

  def internet_connected?
    TMReachability.reachabilityForInternetConnection.isReachable
  end

  def tableView(tableView, heightForRowAtIndexPath: indexPath)
    50
  end

  def tableView(tableView, cellForRowAtIndexPath: indexPath)
    @reuseIdentifier ||= "MenuCell"

    cell = tableView.dequeueReusableCellWithIdentifier(@reuseIdentifier) ||
      UITableViewCell.alloc.initWithStyle(UITableViewCellStyleDefault, reuseIdentifier: @reuseIdentifier)

    if (indexPath.row == 0)
      height = 50
    else
      height = 10
    end

    cell.textLabel.text = @labels[indexPath.row]
    cell.textLabel.textAlignment = UITextAlignmentRight

    return cell
  end

  def tableView(tableView, numberOfSectionsInTableView: sections)
    return 1
  end

  def tableView(tableView, numberOfRowsInSection: section)
    return @labels.length
  end

  def tableView(tableView, didSelectRowAtIndexPath:indexPath)
    tableView.deselectRowAtIndexPath(indexPath, animated: true)
    new_controller = case @labels[indexPath.row]
                        when "Contact Us"
                          ContactController.alloc.initWithNibName(nil, bundle: nil)
                        when "Find Groups"
                          FindGroupsController.alloc.initWithNibName(nil, bundle: nil)
                        when "Create Group"
                          CreateGroupController.alloc.initWithNibName(nil, bundle: nil)
                        when "My Events"
                          EventsController.alloc.initWithNibName(nil, bundle: nil)
                        when "Find Friends"
                          FindFriendsController.alloc.initWithNibName(nil, bundle: nil)
                        when "Inbox"
                          InboxController.alloc.initWithNibName(nil, bundle: nil)
                        when "Log Out"
                          LogoutController.alloc.initWithNibName(nil, bundle: nil)
                        end

    #puts new_controller
    #nav = UINavigationController.alloc.initWithRootViewController(GroupsController.alloc.initWithNibName(nil, bundle: nil))
    #self.pushViewController(new_controller, animated:true)
    if internet_connected?
      self.viewDeckController.rightViewPushViewControllerOverCenterController(new_controller)
    else
      App.alert("Poor internet connection or airplane mode enabled")
    end


  end

end