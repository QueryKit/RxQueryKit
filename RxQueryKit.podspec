Pod::Spec.new do |spec|
  spec.name = 'RxQueryKit'
  spec.version = '0.5.3'
  spec.summary = 'RxSwift extensions for dealing with QueryKit'
  spec.homepage = 'https://github.com/QueryKit/RxQueryKit'
  spec.license = { :type => 'BSD', :file => 'LICENSE' }
  spec.author = { 'Kyle Fuller' => 'kyle@fuller.li' }
  spec.social_media_url = 'http://twitter.com/kylefuller'
  spec.source = { :git => 'https://github.com/QueryKit/RxQueryKit.git', :tag => spec.version }
  spec.frameworks = ['CoreData']
  spec.source_files = 'RxQueryKit/*.swift'
  spec.ios.deployment_target = '8.0'
  spec.osx.deployment_target = '10.9'
  spec.requires_arc = true
  spec.dependency 'RxSwift', '~> 2.0'
  spec.dependency 'QueryKit', '~> 0.12.0'
end

