Pod::Spec.new do |s|
  s.name     = 'AppQuestLogbuch'
  s.version  = '2.0.0'
  s.license  = 'MIT'
  s.summary  = 'Logbuch Applikation für die HSR App Quest'
  s.homepage = 'https://github.com/lightforce/AppQuest'
  s.authors  = { 'Sebastian Hunkeler' => 'shunkele@hsr.ch' }
  s.source   = { :git => 'https://github.com/lightforce/AppQuest.git', :tag => "2.0.0" }
  s.requires_arc = true

  s.ios.deployment_target = '7.0'
  s.dependency 'ZBarSDK', '~> 1.3.1'
  s.public_header_files = 'Logbuch Workspace/Logbuch/Logbuch/Logic/SolutionLogger.swift'
  #s.source_files = 'Logbuch Workspace/Logbuch/Logbuch/Logic/SolutionLogger.swift', 'Logbuch Workspace/Logbuch/Logbuch/UI/QRCodeReaderViewController.swift'
  s.source_files = 'Logbuch Workspace/Logbuch/Logbuch/Logic/SolutionLogger.{h,m}'
  #s.frameworks = 'Foundation', 'UIKit', 'AVFoundation'
  s.frameworks = 'Foundation'
end