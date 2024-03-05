
def shared_pods
  pod 'CloudCore', :path => '../../Libraries/CloudCore'
end

target 'CarShuffle' do
    platform :ios, '17.0'
    use_frameworks!
    
    shared_pods
    
    pod 'Connectivity'
    pod 'WhatsNewKit'
    
    pod 'SwiftDate'
end

# target 'watchOS Extension' do
#    platform :watchos, '7.2'
#    use_frameworks!
#    
#    shared_pods
# end

post_install do |installer|
    installer.pods_project.build_configurations.each do |config|
        config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '17.0'
    end
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '17.0'
        end
    end
end
