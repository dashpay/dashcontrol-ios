platform :ios, '10.0'

inhibit_all_warnings!

def app_pods
    pod 'DashSync', :git => 'git@github.com:dashevo/dashsync-ios.git', :branch => 'master', :commit => 'afaafa3be7be962320ad5eb626e34b0c4b47d9f6'
    pod 'secp256k1_dash', '0.1.0'
    pod 'SDWebImage', '4.3.3'
    pod 'MBCircularProgressBar', '0.3.5'
    pod 'MBProgressHUD', '1.1.0'
    pod 'DeluxeInjection', '0.8.6'
    pod 'KVO-MVVM', '0.5.1'
    pod 'UIViewController-KeyboardAdditions', '1.2.1'
    pod 'Godzippa', '2.0.0'
    
    pod 'SimulatorStatusMagic', :configurations => ['Debug']
end

target 'DashControl' do
  app_pods
end

target 'DashControlTests' do
    app_pods
end
