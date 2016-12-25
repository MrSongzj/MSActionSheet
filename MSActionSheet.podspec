
Pod::Spec.new do |s|

  s.name         = "MSActionSheet"

  s.version      = "1.0.0"

  s.summary      = "仿微信和新浪微博风格的 ActionSheet，使用方便，源码简单易读。"

  s.homepage     = "https://github.com/MrSongzj/MSActionSheet"

  s.license      = { :type => "MIT", :file => "LICENSE" }

  s.author             = { "mrsong" => "424607870@qq.com" }

  s.platform     = :ios, "5.0"

  s.source       = { :git => "https://github.com/MrSongzj/MSActionSheet.git", :tag => "v1.0.0" }

  s.source_files  = "MSActionSheet/*.{h,m}"

end
