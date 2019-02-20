
Pod::Spec.new do |s|
  s.name             = "StickyLocking"
  s.version          = "1.0.0-beta.2"
  s.summary          = "A general purpose embedded hierarchical lock manager used to build highly concurrent applications of all types."

  s.homepage         = "https://github.com/stickytools/sticky-locking"
  s.license          = 'Apache License, Version 2.0'
  s.author           = { "Tony Stone" => "https://github.com/tonystone" }
  s.source           = { :git => "https://github.com/stickytools/sticky-locking.git", :tag => s.version.to_s }

  s.swift_version = '4.0'

  s.ios.deployment_target     = '8.0'
  s.osx.deployment_target     = '10.10'
  s.watchos.deployment_target = '2.0'
  s.tvos.deployment_target    = '9.0'

  s.requires_arc = true

  s.source_files = 'Sources/StickyLocking/**/*.swift'
end
