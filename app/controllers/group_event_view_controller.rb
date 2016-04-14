class GroupEventViewController < UIViewController
  attr_accessor :event, :group_true

  def viewDidLoad
    @labels = ["Name", "Start", "End", "Description", "Delete"]

    titleView = UILabel.alloc.initWithFrame(CGRectZero)
    titleView.backgroundColor = UIColor.clearColor
    titleView.font = UIFont.boldSystemFontOfSize(20.0)
    titleView.shadowColor = UIColor.colorWithWhite(0.0,alpha:0.5)
    titleView.textColor = UIColor.whiteColor
    self.navigationItem.titleView = titleView
    titleView.text = 'Event'
    titleView.sizeToFit
    @group_owner = NSUserDefaults.standardUserDefaults["group-user_id"] 
    @current_user = NSUserDefaults.standardUserDefaults["id"]

    self.navigationController.navigationBar.tintColor = UIColor.whiteColor

    table_frame = [[0, 0],
                   [self.view.frame.size.width, self.view.bounds.size.height - 50]]
    @table = UITableView.alloc.initWithFrame(table_frame)

    @table.delegate = @table.dataSource = self
    self.view.addSubview @table
    @table.dataSource = self
    #set footer height to zero in order to eliminate empty rows at the end of a table
    @table.tableFooterView = UIView.alloc.initWithFrame(CGRectZero)

    self.navigationItem.setHidesBackButton(true)
    leftButton = UIBarButtonItem.alloc.initWithTitle("Back",style:UIBarButtonItemStyleDone,target: self,action:'go_back')
    self.navigationItem.leftBarButtonItem = leftButton

    rightButton = UIBarButtonItem.alloc.initWithTitle("Edit",style:UIBarButtonItemStyleDone,target: self,action:'push_edit')
    self.navigationItem.rightBarButtonItem = rightButton


    #@table.separatorStyle = UITableViewCellSeparatorStyleNone
    self.view.backgroundColor = UIColor.whiteColor
    @table.backgroundColor = UIColor.whiteColor

    #Need to set this dynamically to handle the first cell being larger then the rest
    #@table.rowHeight = 30

    start_at = @event['start_at']
    end_at = @event['end_at']
    truncated_start_at = start_at[0...-6]
    truncated_end_at = end_at[0...-6] if @event['end_at']



    outputFormatter = NSDateFormatter.alloc.init 
    outputFormatter.setDateFormat("yyyy-MM-dd'T'HH:mm:ss")
    start_at_date = outputFormatter.dateFromString(truncated_start_at)
    end_at_date = outputFormatter.dateFromString(truncated_end_at)

    outputFormatter.setDateFormat("yyyy-MM-dd")
    @start_at_string = outputFormatter.stringFromDate(start_at_date)
    @end_at_string = outputFormatter.stringFromDate(end_at_date)

    outputFormatter.setDateFormat("h:mm a")
    @start_at_time = outputFormatter.stringFromDate(start_at_date)
    @end_at_time = outputFormatter.stringFromDate(end_at_date)
 

    #outputFormatter.release
  end

  def internet_connected?
    TMReachability.reachabilityForInternetConnection.isReachable
  end

  def tableView(tableView, heightForRowAtIndexPath: indexPath)
    if @labels[indexPath.row] == "Description"
        description = @event['content']
        size = description.sizeWithFont(UIFont.systemFontOfSize(20), constrainedToSize:[260.0, 300.0], lineBreakMode:UILineBreakModeWordWrap)
        height = (22 + size.height) # 22 is the content margin
        height
    elsif  @labels[indexPath.row] == "Name"
      name = @event['name']
      size = name.sizeWithFont(UIFont.systemFontOfSize(20), constrainedToSize:[260.0, 300.0], lineBreakMode:UILineBreakModeWordWrap)
      height = (22 + size.height) # 22 is the content margin
      height
    else
        50
    end
  end

  def tableView(tableView, cellForRowAtIndexPath: indexPath)
    @reuseIdentifier ||= "MenuCell"
    cell = tableView.dequeueReusableCellWithIdentifier(@reuseIdentifier)

    if cell == nil
      cell ||= UITableViewCell.alloc.initWithStyle( UITableViewCellStyleSubtitle, reuseIdentifier:@reuseIdentifier)
      cell.textLabel.font = UIFont.systemFontOfSize(18)
      cell.textLabel.numberOfLines = 0
    end

    


    cell.textLabel.text  = case @labels[indexPath.row]
                        when "Name"
                          "Name: " + @event['name']
                        when "Start"
                          "Start: "  + @start_at_string + ", " + @start_at_time
                        when "End"
                            if @event['end_at'] != nil
                                "End: " + @end_at_string + ", " + @end_at_time
                            else
                                "End: no end date"
                            end

                        when "Description"
                          "Description: " + @event['content']
                        when "Delete"
                          if @group_owner == @current_user
                            "Delete"
                          end
                        end



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
    if @labels[indexPath.row] == "Delete"
      if @group_owner == @current_user
        delete_event
      end
    end
  end

  def go_back
    if @group_true == true
      new_controller = GroupEventsController.alloc.initWithStyle(UITableViewStylePlain)
    else
      new_controller = EventsController.alloc.initWithStyle(UITableViewStylePlain)
    end
    self.navigationController.pushViewController(new_controller, animated: false)
  end

  def delete_event

    BW::UIAlertView.new({
      buttons: ['Destroy Event', 'Cancel'],
      cancel_button_index: 1
    }) do |alert|
        if alert.clicked_button.cancel?
          #cancelled
        else
          auth_token = @auth_token
          group_id = NSUserDefaults.standardUserDefaults["group-id"]
          event_id = @event["id"]

          GroupEventDestroyService.new(self, { auth_token: auth_token, group_id: group_id, event_id: event_id }).process
        end
      end.show

  end

  def handle_eventdestroy_failed
    App.alert("Something went wrong, please try again")
  end

  def handle_eventdestroy_successful
    new_controller = GroupEventsController.alloc.initWithStyle(UITableViewStylePlain)
    self.navigationController.pushViewController(new_controller, animated: true)
    App.alert("Destroyed Event")
  end

  def push_edit
    new_controller = GroupEventEditController.alloc.initWithNibName(nil, bundle: nil)
    new_controller.event = @event
    self.navigationController.pushViewController(new_controller, animated: false)
  end
end
