#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#
Pod::Spec.new do |s|
  s.name             = 'stripe_native'
  s.version          = '1.0.2'
  s.summary          = 'Create chargeable stripe tokens using Apple and Google Pay.'
  s.description      = <<-DESC
Create chargeable stripe tokens using Apple and Google Pay.
                       DESC
  s.homepage         = 'http://rbitwo.com'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'John Blanchard' => 'jnblanchard@mac.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.public_header_files = 'Classes/**/*.h'
  s.dependency 'Flutter'
  s.dependency 'Stripe', '16.0.6'
  s.swift_version = '4.1'

  s.ios.deployment_target = '11.0'
end

