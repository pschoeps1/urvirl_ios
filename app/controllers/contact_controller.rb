class ContactController < UIViewController
  def viewDidLoad

    super
	titleView = UILabel.alloc.initWithFrame(CGRectZero)
    titleView.backgroundColor = UIColor.clearColor
    titleView.font = UIFont.boldSystemFontOfSize(20.0)
    titleView.shadowColor = UIColor.colorWithWhite(0.0,alpha:0.5)
    titleView.textColor = UIColor.whiteColor
    self.navigationItem.titleView = titleView
    titleView.text = "Contact Us"
    titleView.sizeToFit

    self.navigationController.navigationBar.tintColor = UIColor.whiteColor

	StandardAppearance.set_named_fonts_and_colors
    rmq.stylesheet = MainStylesheet
    rmq(self.view).apply_style :root_view

    @email = MotionKeychain.get('email')
    @auth_token = MotionKeychain.get('auth_token')
    @user = NSUserDefaults.standardUserDefaults["id"]

    mail_capable = BW::Mail.can_send_mail?

    rmq.append(UILabel, :contact_details).get

    if mail_capable
    	rmq.append(UIButton, :email_button).on(:tap) do |_|
          send_mail
        end
    else
    	rmq.append(UILabel, :contact_details).get
    end

end

def send_mail
	BW::Mail.compose(
  delegate: self, # optional, defaults to rootViewController
  to: [ "support@urvirl.com.com" ],
  html: false,
  subject: "Support Message User Id: #{@user}",
  message: "",
  animated: false
) 

end

end
