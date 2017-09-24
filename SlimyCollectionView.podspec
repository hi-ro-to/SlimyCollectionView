Pod::Spec.new do |s|
  s.name         = "SlimyCollectionView"
  s.version      = "0.0.1"
  s.summary      = "SlimyCollectionView is the UICollectionView which scrolls smoothly images."
  s.description  = <<-DESC
This is the UICollectionView which scrolls smoothly images.

Your collectionView will be faster and offer good user experience if you use this when you want to show your users photo or image list.

DESC

  s.homepage              = "https://github.com/hi-ro-to/SlimyCollectionView"
  s.license               = "MIT"
  s.author                = { "piikaachuu" => "bijob.co@gmail.com" }
  s.social_media_url      = "https://twitter.com/piikaachuu00"
  s.source                = { :git => "https://github.com/hi-ro-to/SlimyCollectionView.git", :tag => s.version.to_s }
  s.ios.deployment_target = "9.0"
  s.requires_arc          = true
  s.source_files          = "SlimyCollectionView/*.swift"
  s.exclude_files         = "Classes/Exclude"
  s.dependency              "SDWebImage", "~> 4.0"

end
