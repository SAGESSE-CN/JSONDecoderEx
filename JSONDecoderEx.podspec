#
# Be sure to run `pod lib lint JSONDecoderEx.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'JSONDecoderEx'
  s.version          = '1.0.1'
  s.summary          = 'A enhanced JSON decoder.'
  s.homepage         = 'https://github.com/SAGESSE-CN/JSONDecoderEx'
  s.author           = { 'SAGESSE' => 'gdmmyzc@163.com' }
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.source           = { :git => 'https://github.com/SAGESSE-CN/JSONDecoderEx.git', :tag => s.version.to_s }

  s.swift_versions = '5.0'

  s.ios.deployment_target = '9.0'
  s.osx.deployment_target = '10.11'

  s.subspec 'Core' do |sp|
    sp.source_files = 'Sources/**/*.swift'
  end
  
#s.test_spec 'Tests' do |ts|
#  ts.source_files = 'Tests/**/*'
#end
end
