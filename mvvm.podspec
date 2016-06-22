Pod::Spec.new do |s|
  s.name         = 'mvvm'
  s.version      = '0.1'
  s.license      = 'MIT'
  s.homepage     = 'https://github.com/yinhaofrancis/MVVM'
  s.authors      = '尹豪': '1833918721@qq.com'
  s.summary      = 'mvvm'

  s.platform     =  :ios, '7.0'
  s.source       =  git: 'https://github.com/yinhaofrancis/MVVM.git', :tag => s.version
  s.source_files = 'mvvm/**/*'
  s.frameworks   =  'UIKit'
  s.requires_arc = true
  s.public_header_files = 'mvvm/mvvm.h'
# Pod Dependencies

end
