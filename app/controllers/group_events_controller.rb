class GroupEventsController < UIViewController
  attr_accessor :customDates
  def viewDidLoad
    super

    self.navigationController.navigationBar.hidden = false
    purple = UIColor.colorWithRed(0.306, green:0, blue:0.557, alpha:1)
    self.navigationController.navigationBar.setBarTintColor(purple)
    self.navigationController.navigationBar.setTranslucent(false)
    
    #leftButton = UIBarButtonItem.alloc.initWithTitle("Log Out",style:UIBarButtonItemStyleDone,target: self,action:'logout')
    #self.navigationItem.leftBarButtonItem = leftButton
    self.navigationItem.setHidesBackButton(true)
    leftButton = UIBarButtonItem.alloc.initWithTitle("Back",style:UIBarButtonItemStyleDone,target: self,action:'go_back')
    self.navigationItem.leftBarButtonItem = leftButton

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
    self.customDates = []

    if internet_connected?
        getEventData
    else
        App.alert("Poor internet connection or airplane mode enabled")
    end



   
   





   # view.dataSource = view.delegate = self
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

      #json.sort! { |x, y| x["start_at"] <=> y["start_at"] }
     #   @table.reloadData
     #   scroll_bottom
        
     # }

      new_events = []
      json["events"].each do |dict|
        new_events << dict #Group.new(dict)
      end

      Dispatch::Queue.main.sync { load_events(new_events) }
    end
  end

  def load_events(events)
    @data = events
    initCustomDates
  end


  def initCustomDates



    #components = NSCalendar.currentCalendar.components(NSCalendarUnitMonth|NSCalendarUnitYear, fromDate: NSDate.date)
    #components.day = 15
    #date1 = NSCalendar.currentCalendar.dateFromComponents(components)
    #addOneMonthComponents = NSDateComponents.alloc.init
    #addOneMonthComponents.month = 1
    #date2 = NSCalendar.currentCalendar.dateByAddingComponents(addOneMonthComponents, toDate: date1, options:0)
    #date3 = NSCalendar.currentCalendar.dateByAddingComponents(addOneMonthComponents, toDate:date2, options:0)
    #self.customDates << date1





    @data.each do |event|
      start = event['start_at']
      start_at = start[0...-5]
      formatter = NSDateFormatter.alloc.init
      formatter.setDateFormat("yyyy-MM-dd'T'HH:mm:ss")
      #gmt = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
      #formatter setTimeZone:gmt];
      date = formatter.dateFromString(start_at)
      components = NSCalendar.currentCalendar.components(NSCalendarUnitDay|NSCalendarUnitMonth|NSCalendarUnitYear, fromDate: date)
      new_date = NSCalendar.currentCalendar.dateFromComponents(components)
      #calendarDate = NSCalendar.currentCalendar.dateByAddingComponents(addOneMonthComponents, toDate: date, options:0)
      #puts calendarDate
      self.customDates << new_date
    end

    calendarViewController = PDTSimpleCalendarViewController.alloc.init
    #This is the default behavior, will display a full year starting the first of the current month
    calendarViewController.setDelegate(self)
    calendarViewController.weekdayHeaderEnabled = true
    calendarViewController.weekdayTextType = PDTSimpleCalendarViewWeekdayTextTypeVeryShort

    dateRangeCalendarViewController = PDTSimpleCalendarViewController.alloc.init
    #For this calendar we're gonna allow only a selection between today and today + 3months.
    dateRangeCalendarViewController.firstDate = NSDate.date
    offsetComponents = NSDateComponents.alloc.init
    offsetComponents.month = 3
    lastDate = dateRangeCalendarViewController.calendar.dateByAddingComponents(offsetComponents, toDate: NSDate.date, options:0)
    dateRangeCalendarViewController.lastDate = lastDate
    self.navigationController.pushViewController(calendarViewController, animated: false)


  end

  def simpleCalendarViewController(controller, shouldUseCustomColorsForDate: date)
    if self.customDates.containsObject(date)
      true
    else
      false
    end
      
        
  end

  def simpleCalendarViewCell(cell, shouldUseCustomColorsForDate: date)
    if self.customDates.containsObject(date)
      cell.appearance.setCircleDefaultColor(UIColor.blackColor)
    end
  end

  def simpleCalendarViewController(controller, didSelectDate: date)
    if self.customDates.containsObject(date)
      puts "true"
      group_true = true
      new_controller = GroupEventViewController.alloc.initWithNibName(nil, bundle: nil)
      new_controller.group_true = group_true

      @data.each do |event|
        event_date = event['start_at'][0...-14]
        date_eval =  date.to_s[0..-15]
        puts "event_date"
        puts event_date
        puts "date date"
        puts date_eval
        if event_date == date_eval
          new_controller.event = event
          self.navigationController.pushViewController(new_controller, animated: true)
        end
      end
    end
  end

  def simpleCalendarViewController(controller, circleColorForDate: date)

    UIColor.blackColor
  end


  def simpleCalendarViewController(controller, textColorForDate: date)
    UIColor.orangeColor
  end

  








  def add_event
    new_controller = GroupEventAddController.alloc.initWithNibName(nil, bundle: nil)

    self.navigationController.pushViewController(new_controller, animated: true)
  end

  def go_back
    new_controller = GroupMenuController.alloc.initWithNibName(nil, bundle: nil)
    self.navigationController.pushViewController(new_controller, animated: false)
  end


end

