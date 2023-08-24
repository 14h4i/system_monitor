Pod::Spec.new do |s|
  s.name             = 'system_monitor'
  s.version          = '1.0.3'
  s.summary          = 'A package to monitor system CPU and RAM usage.'
  s.description      = <<-DESC
                       A package to monitor system CPU and RAM usage.
                       DESC
  s.homepage         = 'https://github.com/14h4i/system_monitor'
  s.license          = { :type => 'MIT', :file => '../LICENSE' }
  s.author           = { '14h4i' => 'pgkhai.dev@gmail.com' }
  s.platform         = :ios, '10.0'
  s.source           = { :git => 'https://github.com/14h4i/system_monitor.git', :tag => s.version.to_s }

  s.source_files = 'SystemMonitorMacos/**/*.{h,m,swift}'
  s.exclude_files = 'SystemMonitorMacos/Exclude'
  s.resources = 'SystemMonitorMacos/Resources/**/*'

  s.dependency 'SystemMonitorMacos', '1.0.3'
end