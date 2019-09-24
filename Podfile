platform :ios, '9.0'

def shared_pods
    use_frameworks!
    pod 'RxSwift'
    pod 'pop'
    pod 'BonMot'
    pod 'SpinKit'
	pod 'Fabric', '~> 1.7.9'
	pod 'Crashlytics', '~> 3.10.5'
    pod 'SnapKit'
    pod 'Localize-Swift'
    pod 'Action'
    pod 'Moya/RxSwift'
    pod 'Gloss'
    pod 'Moya-Gloss/RxSwift'
    pod 'KeychainSwift'
    pod 'DeviceKit'
    pod 'Gifu'
    pod 'TPKeyboardAvoiding'
    pod 'SideMenu'
    pod 'RxGesture'
    pod 'GoogleMaps'
    pod 'OneSignal', '>= 2.6.2', '< 3.0'
	pod 'Firebase/Core'
end

target 'Sharengo' do
  use_frameworks!
  shared_pods
end
target 'SharengoNL' do
    use_frameworks!
    shared_pods
end
target 'SharengoSK' do
    use_frameworks!
    shared_pods
end
target 'SharengoSL' do
    use_frameworks!
    shared_pods
end

post_install do |installer|
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['SWIFT_VERSION'] = '4.2'
        end
    end
end
