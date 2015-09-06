Pod::Spec.new do |spec|
  spec.name = 'RxQueryKit'
  spec.version = '0.1.0'
  spec.summary = 'RxSwift extensions for dealing with QueryKit'
  spec.homepage = 'https://github.com/QueryKit/RxQueryKit'
  spec.license = { :type => 'BSD', :file => 'LICENSE' }
  spec.author = { 'Kyle Fuller' => 'kyle@fuller.li' }
  spec.social_media_url = 'http://twitter.com/kylefuller'
  spec.source = { :git => 'https://github.com/kylef/RxQueryKit.git', :tag => spec.version }
  spec.source_files = 'RxQueryKit/*.swift'
  spec.ios.deployment_target = '8.0'
  spec.osx.deployment_target = '10.9'
  spec.requires_arc = true
  spec.dependency 'QueryKit'
end

