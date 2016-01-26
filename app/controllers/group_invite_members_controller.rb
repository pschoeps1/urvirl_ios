class GroupInviteMembersController < UIViewController
    attr_accessor :group, :blocked_users
  
  def viewDidLoad
    @data = NSMutableArray.alloc.init
    @keys = @data.map { |r| r.name }
    @email = MotionKeychain.get('email')
    @auth_token = MotionKeychain.get('auth_token')
    @user = NSUserDefaults.standardUserDefaults["id"]
    @name = MotionKeychain.get('name')
    super

    self.view.frame.size.height = 800

    rightButton = UIBarButtonItem.alloc.initWithTitle("Cancel",style:UIBarButtonItemStyleDone,target: self,action:'resign_keyboard')
    self.navigationItem.rightBarButtonItem = rightButton


    blue = UIColor.colorWithRed(0.00,green:0.64,blue:0.88,alpha:1.0)

    titleView = UILabel.alloc.initWithFrame(CGRectZero)
    titleView.backgroundColor = UIColor.clearColor
    titleView.font = UIFont.boldSystemFontOfSize(20.0)
    titleView.shadowColor = UIColor.colorWithWhite(0.0,alpha:0.5)
    titleView.textColor = UIColor.whiteColor
    self.navigationItem.titleView = titleView
    titleView.text = "Invite Members"
    titleView.sizeToFit

    self.navigationController.navigationBar.tintColor = UIColor.whiteColor

    StandardAppearance.set_named_fonts_and_colors
    rmq.stylesheet = MainStylesheet
    rmq(self.view).apply_style :root_view

    rmq.append(UIView, :group_invite_form).tap do |q|
      @group_invited = q.append(UITextView, :group_invited).get
      q.append(UIButton, :group_invite_button).on(:tap) do |_|
        if internet_connected?
          invite_members
        else
          App.alert("Poor internet connection or airplane mode enabled")
        end
      end
    end

    @group_invited.placeholder = "enter email addresses separated by comma"
    @group_invited.placeholderColor = UIColor.lightGrayColor
    @group_invited.layer.setBorderColor(UIColor.grayColor.CGColor)
    @group_invited.layer.setBorderWidth(1)
    @group_invited.layer.setCornerRadius(5)

  end

  def internet_connected?
    TMReachability.reachabilityForInternetConnection.isReachable
  end

  def handle_server_error
    App.alert('something went wrong')
  end

  def invite_members
    if @group_invited.text.length == 0
        App.alert("Please enter at least one email")
    else
        group_id = NSUserDefaults.standardUserDefaults["group-id"]
        multiple_invites = @group_invited.text
        auth_token = @auth_token
        user_id = @user

        GroupInviteService.new(self, {multiple_invites: multiple_invites, auth_token: auth_token, group_id: group_id, user_id: user_id}).process
    end
    @group_invited.resignFirstResponder
    @group_invited.setText("")
  end

  def handle_invites_failed
        App.alert("Something went wrong, please try again")
  end

  def handle_invites_successful
      App.alert("Invites sent.")
  end

  def resign_keyboard
    self.view.endEditing(true)
  end 
end


