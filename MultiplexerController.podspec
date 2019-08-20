Pod::Spec.new do |s|
  s.name         = "MultiplexerController"
  s.version      = "1.0.0"
  s.summary      = "Present controllers as a function of state"
  s.description  = <<-DESC
    MultiplexerController is a containment controller that can dynamically switch its presented child based on a state object.
    Constructing screens in this manner results in smaller and more reusable view code.
    The controller handles the view management, presentation and transitions automatically.
  DESC
  s.homepage     = "https://github.com/mobiten/multiplexer-controller"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author             = { "Charles-Henri Dumalin" => "charles-henri@mobiten.com" }
  s.ios.deployment_target = "10.0"
  s.source       = { :git => "https://github.com/mobiten/multiplexer-controller.git", :tag => s.version.to_s }
  s.source_files  = "Sources/**/*"
  s.ios.framework  = 'UIKit'
  s.swift_versions = ["4.2", "5.0"]
end
