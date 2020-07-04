# Uncomment this line to define a global platform for your project
# platform :ios, '9.0'

target 'letscheers' do
  # Comment this line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!
  inhibit_all_warnings!

  # Pods for letscheers
  pod 'Firebase/Core'
  pod 'Firebase/AdMob'
  pod 'Firebase/Analytics'

  pod 'XlsxReaderWriter'
  pod 'KakaoOpenSDK'
  pod 'RxSwift',  '~> 4.0'
  pod 'RxCocoa', '~> 4.0'
  pod 'LSExtensions', :path => '~/Projects/leesam/pods/LSExtensions/src/LSExtensions'
  pod 'GADManager', :path => '~/Projects/leesam/pods/GADManager/src/GADManager'

  # Add the pod for Firebase Crashlytics
  pod 'Firebase/Crashlytics'

  # Recommended: Add the Firebase pod for Google Analytics
  pod 'Firebase/Analytics'
  
  target 'letscheersTests' do
    inherit! :search_paths
    # Pods for testing
  end

  target 'letscheersUITests' do
    inherit! :search_paths
    # Pods for testing
  end

    #script to do after install pod projects
    post_install do |installer|
        #find target name of "XlsxReaderWriter" from targets in Pods
        XlsxReaderWriter = installer.pods_project.targets.find{ |t| t.name == "XlsxReaderWriter" }
        #puts "capture #{XlsxReaderWriter}";
        #find target name of "XMLDictionary" from targets in Pods
        XMLDictionary = installer.pods_project.targets
        .find{ |t| t.name == "XMLDictionary" }
        #puts "capture #{XMLDictionary}";
        #find file reference for "XMLDictionary.h" of a Project "XMLDictionary"
        XMLDictionaryHeader = XMLDictionary.headers_build_phase.files
        .find{ |b| b.file_ref.name == "XMLDictionary.h" }.file_ref
        
        #add reference for "XMLDictionary.h" into project "XlsxReaderWriter"
        XMLDictionaryHeaderBuild = XlsxReaderWriter.headers_build_phase.add_file_reference(XMLDictionaryHeader, avoid_duplicates = true);
        #make new file appended public
        XMLDictionaryHeaderBuild.settings = { "ATTRIBUTES" => ["Public"] }
        puts "add #{XMLDictionaryHeader} into XlsxReaderWriter";
    end
end
