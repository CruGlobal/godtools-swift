
source 'https://cdn.cocoapods.org/'
source 'https://github.com/CruGlobal/cocoapods-specs.git'

# Uncomment this line to define a global platform for your project
platform :ios, '14.0'

# Specs finder:
# https://github.com/CocoaPods/Specs/find/master

def shared_pods
  
  # CruGlobal pods
  pod 'GodToolsShared', '1.1.0-SNAPSHOT'
end

target 'godtools' do
            
    shared_pods
end

target 'godtoolsTests' do
      
  shared_pods
end

target 'godtoolsUITests' do
    
  shared_pods
end
