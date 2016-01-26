# -*- coding: utf-8 -*-
# -*- coding: utf-8 -*-
$:.unshift("/Library/RubyMotion/lib")
require 'motion/project/template/ios'

begin
  require 'motion-cocoapods'
  require 'bundler'
  require 'bubble-wrap/all'
  require 'bubble-wrap/mail'
  require 'motion-installr'
 # require 'motion-blitz'
  Bundler.require
rescue LoadError
end

Motion::Project::App.setup do |app|
  # Use `rake config' to see complete project settings.
  app.name = 'urvirl'
  app.icons = ['Icon.png', 'Icon-72@2x.png', 'Icon-72.png', 'Icon-Small-20.png', 'Icon-Small-20@2x.png','Icon-Small-30.png','Icon-Small-30@2x.png', 'Icon-Small-50.png','Icon-Small-50@2x.png','Icon-Small.png', 'Icon-Small@2x.png', 'Icon.png', 'Icon@2x.png', 'apple-touch-icon-120x120.png', 'apple-touch-icon-152x152.png', 'apple-touch-icon-76x76.png']
  app.version = "1.0.14"
  app.identifier = 'com.youcompany.urvirl'
  #app.provisioning_profile = '/Users/mac/downloads/app_development.mobileprovision'
  #app.codesign_certificate = 'iPhone Developer: Patrick Schoes (N294G47R68)'
  app.device_family = [:iphone, :ipad]
  app.detect_dependencies = false
  app.interface_orientations = [:portrait]
  app.deployment_target = "8.0"
  #app.entitlements['get-task-allow'] = false
  #app.installr_api_token = 'DNWENnGJl1XHKV4CvtuyosPhi1AfRZs7'
  #app.deployment_target = '9.1'
  app.development do
    app.entitlements["aps-environment"] = "development"
    app.provisioning_profile = '/Users/mac/downloads/app_development.mobileprovision'
    app.codesign_certificate = 'iPhone Developer: Patrick Schoes (N294G47R68)'
  end
  # Building for Ad Hoc or App Store distribution
  app.release do
    app.entitlements["aps-environment"] = "production"
    app.codesign_certificate = 'iPhone Distribution: CADel Solutions, Inc (PGQD84MQ42)'
    app.provisioning_profile = '/Users/mac/downloads/urvirl_release.mobileprovision'
  end
  app.info_plist["UIRequiresFullScreen"] = true
  app.info_plist['NSAppTransportSecurity'] = {
      'NSExceptionDomains' => {
          'http://mighty-mesa-2159.herokuapp.com' => { 'NSTemporaryExceptionAllowsInsecureHTTPLoads' => true }
      }
  }
  app.info_plist['NSAppTransportSecurity'] = { 'NSAllowsArbitraryLoads' => true }
  app.info_plist["LSRequiresIPhoneOS"] = true
  app.fonts = ['tw-cent-bold.ttf']

  app.frameworks += [
    'QuartzCore'
  ]

  app.pods do
    pod 'TMReachability', :git => 'https://github.com/albertbori/Reachability', :commit => 'e34782b386307e386348b481c02c176d58ba45e6'
    pod 'SVProgressHUD', :head
    pod 'UITextView+Placeholder'
    pod 'SSKeychain'
    pod 'ViewDeck', '~> 2.4'
  end
end
#task :"build:simulator" => :"schema:build"

