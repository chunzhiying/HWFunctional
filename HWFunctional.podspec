#
#  Be sure to run `pod spec lint HWFunctional.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see http://docs.cocoapods.org/specification.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |s|

  s.name         = "HWFunctional"
  s.version      = "0.3.7"
  s.summary      = "Functional tools for Objective-C."

  s.description  = <<-DESC
    Functional tools for Objective-C. Include HWRxObserver、HWPromise、HWAnimation.
                   DESC

  s.homepage     = "https://github.com/chunzhiying"

  s.license      = "MIT"

  s.author       = { "chunzhiying" => "chun.zhiying.ggl@gmail.com" }
  
  s.platform     = :ios, "7.0"
  s.source       = { :git => "https://github.com/chunzhiying/HWFunctional.git", :tag => "#{s.version}"}
  s.source_files  = "Classes/**/*.{h,m}"
  s.frameworks = "UIKit", "QuartzCore", "Foundation"


  # ――― Project Settings ――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  If your library depends on compiler flags you can set them in the xcconfig hash
  #  where they will only apply to your library. If you depend on other Podspecs
  #  you can include multiple dependencies to ensure it works.

  # s.requires_arc = true

  # s.xcconfig = { "HEADER_SEARCH_PATHS" => "$(SDKROOT)/usr/include/libxml2" }
  # s.dependency "JSONKit", "~> 1.4"

end
