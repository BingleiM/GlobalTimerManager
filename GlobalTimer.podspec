#
#  Be sure to run `pod spec lint GlobalTimer.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see https://guides.cocoapods.org/syntax/podspec.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |spec|
  spec.name         = "TimerManager"
  spec.version      = "1.0.0"
  spec.swift_versions = "4.0"
  spec.summary      = "A global timer manager."
  spec.description  = <<-DESC
                     A simple and easy to user global timer
                   DESC
  spec.homepage     = "https://github.com/BingleiM/GlobalTimerManager"
  spec.license      = { :type => "MIT", :file => "LICENSE" }
  spec.author             = { "mabinglei" => "bingleima@qq.com" }
  spec.ios.deployment_target = "10.0"
  spec.source       = { :git => "https://github.com/BingleiM/GlobalTimerManager.git", :tag => spec.version }
  spec.source_files = "GlobalTimer/*.{swift,h}"
  spec.requires_arc = true
end
