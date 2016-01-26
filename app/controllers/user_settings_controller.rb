class UserSettingsController < UIViewController
    attr_accessor :group, :blocked_users
  
  def viewDidLoad
    @data = NSMutableArray.alloc.init
    @keys = @data.map { |r| r.name }
    @email = MotionKeychain.get('email')
    @auth_token = MotionKeychain.get('auth_token')
    @user = NSUserDefaults.standardUserDefaults["id"]
    @name = MotionKeychain.get('name')
    super


    blue = UIColor.colorWithRed(0.00,green:0.64,blue:0.88,alpha:1.0)

    titleView = UILabel.alloc.initWithFrame(CGRectZero)
    titleView.backgroundColor = UIColor.clearColor
    titleView.font = UIFont.boldSystemFontOfSize(20.0)
    titleView.shadowColor = UIColor.colorWithWhite(0.0,alpha:0.5)
    titleView.textColor = UIColor.whiteColor
    self.navigationItem.titleView = titleView
    titleView.text = "Settings"
    titleView.sizeToFit

    self.navigationController.navigationBar.tintColor = UIColor.whiteColor

    StandardAppearance.set_named_fonts_and_colors
    rmq.stylesheet = MainStylesheet
    rmq(self.view).apply_style :root_view

    rmq.append(UIButton, :group_leave_button).on(:tap) do |_|
        if internet_connected?
            leave_group_confirmation
        else
            App.alert("Poor internet connection or airplane mode enabled")
        end
    end
   
    rmq.append(UIButton, :group_list_members_second).on(:tap) do |_|
        if internet_connected?
            list_members
        else
            App.alert("Poor internet connection or airplane mode enabled")
        end
    end

  end

  def internet_connected?
    TMReachability.reachabilityForInternetConnection.isReachable
  end

  def list_members
    new_controller = GroupListMembersController.alloc.initWithNibName(nil, bundle: nil)
    self.navigationController.pushViewController(new_controller, animated: true)
  end

  def leave_group_confirmation
    BW::UIAlertView.new({
      buttons: ['Leave Group', 'Cancel'],
      cancel_button_index: 1
    }) do |alert|
        if alert.clicked_button.cancel?
          #cancelled
        else
          leave_group
        end
      end.show
  end

  def leave_group
      auth_token = @auth_token 
      followed_id = NSUserDefaults.standardUserDefaults["group-id"] 
      if internet_connected?
        GroupLeaveService.new(self, {auth_token: auth_token, followed_id: followed_id}).process
      else
        App.alert("Poor internet connection or airplane mode enabled")
      end
  end

  def handle_groupleave_failed
    App.alert('Something went wrong, please try again.')
  end

  def handle_groupleave_successful
    new_controller = GroupsController.alloc.initWithStyle(UITableViewStylePlain)
    self.navigationController.pushViewController(new_controller, animated: true)
    App.alert('Group Left')
  end

  def go_back
    new_controller = ChatController.alloc.initWithNibName(nil, bundle: nil)
    self.navigationController.pushViewController(new_controller, animated: false)
  end
 end