class GroupEventViewController < UIViewController
  attr_accessor :event

  def viewDidLoad
    @labels = ["Name", "Start", "End", "Description"]

    titleView = UILabel.alloc.initWithFrame(CGRectZero)
    titleView.backgroundColor = UIColor.clearColor
    titleView.font = UIFont.boldSystemFontOfSize(20.0)
    titleView.shadowColor = UIColor.colorWithWhite(0.0,alpha:0.5)
    titleView.textColor = UIColor.whiteColor
    self.navigationItem.titleView = titleView
    titleView.text = 'Event'
    titleView.sizeToFit

    self.navigationController.navigationBar.tintColor = UIColor.whiteColor

    table_frame = [[0, 0],
                   [self.view.frame.size.width, self.view.bounds.size.height - 50]]
    @table = UITableView.alloc.initWithFrame(table_frame)

    @table.delegate = @table.dataSource = self
    self.view.addSubview @table
    @table.dataSource = self

    self.navigationItem.setHidesBackButton(true)
    leftButton = UIBarButtonItem.alloc.initWithTitle("Back",style:UIBarButtonItemStyleDone,target: self,action:'go_back')
    self.navigationItem.leftBarButtonItem = leftButton


    #@table.separatorStyle = UITableViewCellSeparatorStyleNone
    self.view.backgroundColor = UIColor.whiteColor
    @table.backgroundColor = UIColor.whiteColor

    #Need to set this dynamically to handle the first cell being larger then the rest
    #@table.rowHeight = 30
  end

  def internet_connected?
    TMReachability.reachabilityForInternetConnection.isReachable
  end

  def tableView(tableView, heightForRowAtIndexPath: indexPath)
    if @labels[indexPath.row] == "Description" || "Name"
        description = @event['content']
        size = description.sizeWithFont(UIFont.systemFontOfSize(18), constrainedToSize:[260.0, 300.0], lineBreakMode:UILineBreakModeWordWrap)
        height = (22 + size.height) # 22 is the content margin
        height
    else
        30
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
                          "Start: " + @event['start_at']
                        when "End"
                            if @event['end_at'] != nil
                              "End: " + @event['end_at']
                            else
                                "End: no end date"
                            end

                        when "Description"
                          "Description: " + @event['content']
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
  end

  def go_back
    new_controller = GroupMenuController.alloc.initWithNibName(nil, bundle: nil)
    self.navigationController.pushViewController(new_controller, animated: false)
  end
end
