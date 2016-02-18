class StandardAppearance
  class << self
    def set_named_fonts_and_colors
      rmq = RubyMotionQuery::RMQ
      font = rmq.font
      color = rmq.color

      font_family = 'tw-cent-bold'#'HelveticaNeue-Light'
      font_family_large = 'tw-cent-bold'#'HelveticaNeue-UltraLight'
      font.add_named :huge,           font_family_large, 60
      font.add_named :larger,         font_family_large, 30
      font.add_named :large,          font_family, 20
      font.add_named :medium,         font_family, 16
      font.add_named :small,          font_family, 12
      font.add_named :tiny,           font_family, 9

      color.add_named :tint_color,     '3F5C7A'

      color.add_named :dark_green,     '00BF6F'
      color.add_named :charcoal_gray,  '262626'
      color.add_named :dim_gray,       '7F7F7F'
      color.add_named :light_gray,     'F1F1F1'
      color.add_named :border_color,   'DDDDDD'
      color.add_named :burnt_orange,   'D56217'
      color.add_named :light_peach,    color.from_rgba(250, 57, 66, 0.330)
      color.add_named :red,            'EF426F'
      color.add_named :purple,         '4E008E'
      color.add_named :blue,           '00A3E0'
    end
  end

end

class ApplicationStylesheet < RubyMotionQuery::Stylesheet
  def standard_button(st)
    st.frame = { height: 35 }
    st.color = color.white
    st.background_color = color.blue
    st.view.font = font.large
  end

  def standard_button_as_link(st)
    st.frame = { height: 35 }
    st.color = color.tint_color
    st.view.titleLabel.lineBreakMode = NSLineBreakByWordWrapping
    st.view.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft
  end

  def standard_label_title(st)
    st.number_of_lines = :unlimited
    st.frame = { height: 30 }
  end

  def standard_label_note(st)
    st.number_of_lines = :unlimited
    st.frame = { height: 50 }
    st.color = color.gray
  end

end


class MainStylesheet < ApplicationStylesheet

  def root_view(st)
    st.background_color = color.white
  end

  def label(st)
    st.frame = { top: 150, width: 200, height: 30 }
    st.text = "urvirl"
    st.view.font = font.huge
    st.color = color.blue
    st.text_alignment = :center
  end

  def login_button(st)
    fields st
    standard_button st
    st.frame = { top: 200 }
    st.text = 'Login'
  end

  def signup_button(st)
    fields st
    standard_button st
    st.frame = { top: 240 }
    st.text = 'Sign Up'
  end

  def group_creation_button(st)
    fields st
    standard_button st
    st.frame = { top: 240 }
    st.text = 'Create Group'
  end

  def event_creation_button(st)
    fields st
    standard_button st
    st.frame = { top: 545 }
    st.text = 'Create Event'
  end

  def event_edit_button(st)
    fields st
    standard_button st
    st.frame = { top: 545 }
    st.text = 'Edit Event'
  end

  def group_destroy_button(st)
    fields st
    st.frame = { top: 420, height: 35, width: 260 }
    st.frame = { centered: :horizontal }
    st.text = "Destroy Group"
    st.background_color = color.red
    st.color = color.white
    st.view.font = font.large
  end

  def group_leave_button(st)
    fields st
    st.frame = { top: 60, height: 35, width: 260 }
    st.frame = { centered: :horizontal }
    st.text = "Leave Group"
    st.background_color = color.red
    st.color = color.white
    st.view.font = font.large
  end

  def group_edit_button(st)
    fields st
    standard_button st
    st.frame = { top: 240 }
    st.text = 'Edit Group'
  end

  def group_invite_button(st)
    fields st
    standard_button st
    st.frame = { top: 100 }
    st.text = 'Invite Members'
  end

  def group_invite_friends_button(st)
    fields st
    standard_button st
    st.frame = { top: 300 }
    st.text = 'Invite Friends'
  end

  def group_invite_members_button(st)
    fields st
    standard_button st
    st.frame = { top: 340 }
    st.text = 'Invite Members'
  end

  def group_list_members(st)
    fields st
    standard_button st
    st.frame = { top: 380 }
    st.text = 'Members in group'
  end

  def group_list_members_second(st)
    fields st
    standard_button st
    st.frame = { top: 100 }
    st.text = 'Members in group'
  end


  def logo(st)
    st.frame = {top: 80, width: 100, height: 75}
    st.frame = { centered: :horizontal }
    st.background_image =  image.resource('urvirl-logo-400')
  end

  def first_screen(st)
    st.frame = { top: 80, width: 100, height: 75}
    st.frame = { centered: :horizontal }
    st.background_image =  image.resource('urvirl-logo-400')
  end




  def email(st)
    fields st
    st.frame = { top: 100 }
    st.view.tap do |view|
      view.placeholder = 'Your email address'
      view.clearButtonMode = UITextFieldViewModeWhileEditing
      view.keyboardType = UIKeyboardTypeEmailAddress
      view.borderStyle = UITextBorderStyleRoundedRect
      view.autocorrectionType = UITextAutocorrectionTypeNo
    end
  end

  def signup_email(st)
    fields st
    st.frame = { top: 40 }
    st.view.tap do |view|
      view.placeholder = 'Your email address'
      view.clearButtonMode = UITextFieldViewModeWhileEditing
      view.keyboardType = UIKeyboardTypeEmailAddress
      view.borderStyle = UITextBorderStyleRoundedRect
      view.autocorrectionType = UITextAutocorrectionTypeNo
    end
  end

  def name(st)
    fields st
    st.frame = { top: 90 }
    st.view.tap do |view|
      view.placeholder = 'First and last name'
      view.clearButtonMode = UITextFieldViewModeWhileEditing
      view.keyboardType = UIKeyboardTypeEmailAddress
      view.borderStyle = UITextBorderStyleRoundedRect
      view.autocorrectionType = UITextAutocorrectionTypeNo
    end
  end

  def password(st)
    fields st
    st.frame = { top: 150 }
    st.view.tap do |view|
      view.placeholder = 'Password'
      view.clearButtonMode = UITextFieldViewModeWhileEditing
      st.view.secureTextEntry = true
      view.borderStyle = UITextBorderStyleRoundedRect
      view.autocorrectionType = UITextAutocorrectionTypeNo
    end
  end

  def signup_password(st)
    fields st
    st.frame = { top: 140 }
    st.view.tap do |view|
      view.placeholder = 'Password'
      view.clearButtonMode = UITextFieldViewModeWhileEditing
      st.view.secureTextEntry = true
      view.borderStyle = UITextBorderStyleRoundedRect
      view.autocorrectionType = UITextAutocorrectionTypeNo
    end
  end

  def password_confirmation(st)
    fields st
    st.frame = { top: 190}
    st.view.tap do |view|
      view.placeholder = 'Password confirmation'
      view.clearButtonMode = UITextFieldViewModeWhileEditing
      st.view.secureTextEntry = true
      view.borderStyle = UITextBorderStyleRoundedRect
      view.autocorrectionType = UITextAutocorrectionTypeNo
    end
  end

  def group_name(st)
    fields st
    st.frame = { t: 0 }
    st.view.tap do |view|
      view.placeholder = 'Name'
      view.clearButtonMode = UITextFieldViewModeWhileEditing
      view.borderStyle = UITextBorderStyleRoundedRect
      view.autocorrectionType = UITextAutocorrectionTypeNo
    end
  end

  def group_owner(st)
    fields st
    st.frame = { t: 50 }
    st.view.tap do |view|
      view.placeholder = 'Owner (optional)'
      view.clearButtonMode = UITextFieldViewModeWhileEditing
      view.borderStyle = UITextBorderStyleRoundedRect
      view.autocorrectionType = UITextAutocorrectionTypeNo
    end
  end

  def group_description(st)
    fields st
    st.frame = { t: 100 }
    st.view.tap do |view|
      view.placeholder = 'Description (optional)'
      view.clearButtonMode = UITextFieldViewModeWhileEditing
      view.borderStyle = UITextBorderStyleRoundedRect
      view.autocorrectionType = UITextAutocorrectionTypeNo
    end
  end

   def event_name(st)
    fields st
    st.frame = { t: 0 }
    st.view.tap do |view|
      view.placeholder = 'Name'
      view.clearButtonMode = UITextFieldViewModeWhileEditing
      view.borderStyle = UITextBorderStyleRoundedRect
      view.autocorrectionType = UITextAutocorrectionTypeNo
    end
  end

  def start_at_label(st)
    st.frame = { top: 80, width: 250, height: 30, left: -50 }
    st.text = "Start Date"
    st.view.font = font.medium
  end

  def end_at_label(st)
    st.frame = { top: 320, width: 250, height: 30, left: -50 }
    st.text = "End Date"
    st.view.font = font.medium
  end

  def start_at(st)
    #st.frame = {l: 0, t: 0, w: 260, h: 30}
    st.frame = { centered: :horizontal }
    st.date_picker_mode = :date_and_time
    st.frame = { t: 100 }
  end

  def end_at(st)
    #st.frame = {l: 0, t: 0, w: 260, h: 30}
    st.frame = { centered: :horizontal }
    st.date_picker_mode = :date_and_time
    st.frame = { t: 340 }
  end

  def event_content(st)
    fields st
    st.frame = { t: 40 }
    st.view.tap do |view|
      view.placeholder = 'Content'
      view.clearButtonMode = UITextFieldViewModeWhileEditing
      view.borderStyle = UITextBorderStyleRoundedRect
      view.autocorrectionType = UITextAutocorrectionTypeNo
    end
  end

  def text_field
    #st.frame = { left: 40, width: (rmq.device.width - 80), top: (rmq.device.height - 105), height: 40 }
    st.font = font.large
    st.editable = true
    st.scroll_enabled = true
    st.paging = true
    #content_offset= CGPointMake(-100, 0)
    content_inset = CGPointMake(-200, 0)
    st.content_size = CGSizeMake(320, 500)
  end

  def privacy_label(st)
    st.frame = { top: 160, width: 250, height: 30, left: 15 }
    st.text = "Make group private?"
    st.view.font = font.medium
    st.color = color.blue
  end

  def events_label(st)
    st.frame = { top: 210, width: 250, height: 30, left: 15 }
    st.text = "Members can create events?"
    st.view.font = font.medium
    st.color = color.blue
  end

  def group_invited(st)
    st.frame = { top: 0, width: 250, height: 90 }
    st.view.font = font.large
  end


  def fields(st)
    st.frame = {l: 0, t: 0, w: 260, h: 30}
    st.frame = { centered: :horizontal }
    st.background_color = color.white
    st.border_color = color.blue
  end


  def login_form(st)
    st.frame = {t: 120, w: 200, h: 250}
    st.frame = { centered: :horizontal }
  end

  def signup_form(st)
    st.frame = {t: 0, w: 200, h: 500}
    st.frame = { centered: :horizontal }
  end

  def group_creation_form(st)
    st.frame = {t: 20, w: 200, h: 600 }
    st.frame = { centered: :horizontal }
  end

  def event_creation_form(st)
    st.frame = {t: 20, w: 200, h: 1000 }
    st.frame = { centered: :horizontal }
  end

  def group_edit_form(st)
    st.frame = {t: 20, w: 200, h: 600 }
    st.frame = { centered: :horizontal }
  end

  def group_invite_form(st)
    st.frame = {t: 10, w: 250, h: 200 }
    st.frame = {centered: :horizontal}
  end

  def privacy_policy_link(st)
    st.frame = { top: 405, w: 250, h: 30 }
    st.frame = { centered: :horizontal }
    st.text = 'View our Privacy Policy'
    st.color = color.blue
    st.view.font = font.medium
    st.text_alignment = :center
  end

  def privacy_policy_link_signup(st)
    st.frame = { top: 280, w: 300, h: 30 }
    st.frame = { centered: :horizontal }
    st.text = 'View our privacy policy'
    st.color = color.blue
    st.view.font = font.tiny
    st.text_alignment = :center
  end

  def sign_up_link(st)
    st.frame = { top: 380, w: 250, h: 30  }
    st.frame = { centered: :horizontal }
    st.text = 'No account? Sign up here.'
    st.color = color.blue
    st.view.font = font.medium
    st.text_alignment = :center
  end

  def header(st)
    st.frame = {top: 20, width: 200, height: 25 }
    st.frame = { centered: :horizontal }
  end

  def contact_details(st)
    st.frame = { top: 200, width: 250, height: 30 }
    st.text = "Contact Us: support@urvirl.com"
    st.view.font = font.medium
    st.color = color.blue
    st.frame = { centered: :horizontal }
  end


  def email_button(st)
    fields st
    standard_button st
    st.frame = { top: 250 }
    st.text = 'Email Support'
  end

end