#
# Be sure to run `pod lib lint Nariko.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'Nariko'
  s.version          = '0.1.5'
s.summary          = 'Nariko.io is the first visual feedback tool for mobile apps, which allows users to give feedback about application designs and mobile UX'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
    Nariko.io is the first visual feedback tool for mobile apps, which allows users to give feedback about application designs and mobile user experience. Users can simply draw or drop a pin while adding a comment anywhere where they’ve discovered a bug within the app or are looking to change a certain component. Nariko.io supports quick iterations, agile development, and front-end UI issue reporting in mobile apps.
                       DESC

  s.homepage         = 'https://github.com/inoity/Nariko'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Zsolt Papp' => 'pappzsolt100@gmail.com' }
  s.source           = { :git => 'https://github.com/inoity/Nariko.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '8.0'

  s.source_files = 'Nariko/Classes/**/*'

  # s.ios.resource_bundle = { 'Settings' => ['Nariko/*.lproj','Nariko/Root.plist'] }
  # s.prepare_command = 'chmod u+x $(pwd)/Nariko/settings-script.sh'

  s.resource_bundles = {
    'Nariko' => ['Nariko/Assets/*.{png,xcassets}']
  }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  s.dependency 'SwiftHTTP', '~> 1.0.5'
end
