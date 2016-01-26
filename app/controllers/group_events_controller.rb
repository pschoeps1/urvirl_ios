class GroupEventsController < UITableViewController
  def viewDidLoad
    super

    self.navigationController.navigationBar.hidden = false
    purple = UIColor.colorWithRed(0.306, green:0, blue:0.557, alpha:1)
    self.navigationController.navigationBar.setBarTintColor(purple)
    self.navigationController.navigationBar.setTranslucent(false)
    
    #leftButton = UIBarButtonItem.alloc.initWithTitle("Log Out",style:UIBarButtonItemStyleDone,target: self,action:'logout')
    #self.navigationItem.leftBarButtonItem = leftButton
    self.navigationItem.setHidesBackButton(false)

    rightButton = UIBarButtonItem.alloc.initWithBarButtonSystemItem(UIBarButtonSystemItemAdd, target:self, action: 'add_event')
    self.navigationItem.rightBarButtonItem = rightButton

    @data = []
    @email = MotionKeychain.get('email')
    @auth_token = MotionKeychain.get('auth_token')
    @user = NSUserDefaults.standardUserDefaults["id"]

    titleView = UILabel.alloc.initWithFrame(CGRectZero)
    titleView.backgroundColor = UIColor.clearColor
    titleView.font = UIFont.boldSystemFontOfSize(20.0)
    titleView.shadowColor = UIColor.colorWithWhite(0.0,alpha:0.5)
    titleView.textColor = UIColor.whiteColor
    self.navigationItem.titleView = titleView
    titleView.text = "Events"
    titleView.sizeToFit
  

    rmq.stylesheet = MainStylesheet
    rmq(self.view).apply_style :root_view


    view.dataSource = view.delegate = self
    if internet_connected?
          getEventData
    else
          App.alert("Poor internet connection or airplane mode enabled")
    end
  end


  def internet_connected?
    TMReachability.reachabilityForInternetConnection.isReachable
  end

  def getEventData
    user_data = NSUserDefaults.standardUserDefaults["id"]
    auth_token = MotionKeychain.get('auth_token')
    group_id = NSUserDefaults.standardUserDefaults["group-id"]

    url = "http://mighty-mesa-2159.herokuapp.com/v1/groups/#{group_id}/events?auth_token=#{auth_token}"


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

      new_events = []
      json["events"].each do |dict|
        new_events << dict #Group.new(dict)
      end

      Dispatch::Queue.main.sync { load_events(new_events) }
    end
  end

  def load_events(events)
    @data = events
    view.reloadData
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

    new_controller = GroupEventViewController.alloc.initWithNibName(nil, bundle: nil)
    new_controller.event = @data[indexPath.row]

    self.navigationController.pushViewController(new_controller, animated: true)

  end

  def add_event
    new_controller = GroupEventAddController.alloc.initWithNibName(nil, bundle: nil)

    self.navigationController.pushViewController(new_controller, animated: true)
  end


end

