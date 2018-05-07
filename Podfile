# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

target 'CobaCall' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!

  # Pods for CobaCall
  # pod 'QiscusCallSDKWrapper', :path => './Module/qiscus-call-sdk-wrapper-ios'
   pod 'QiscusCallSDKWrapper', :git => 'https://github.com/qiscus/qiscus-call-sdk-wrapper-ios.git'
  target 'CobaCallTests' do
    inherit! :search_paths
    # Pods for testing
  end

  target 'CobaCallUITests' do
    inherit! :search_paths
    # Pods for testing
  end

end

post_install do |installer|
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['ENABLE_BITCODE'] = 'NO'
        end
    end
end
