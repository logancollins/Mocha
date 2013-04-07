Pod::Spec.new do |s|
  s.name         = "Mocha"
  s.version      = "0.0.1"
  s.summary      = "Objective-C / JavaScript Bridge and Scripting Environment."
  s.description  = "Mocha is a runtime that bridges JavaScript to Objective-C. It is built on top of JavaScriptCore, the component of WebKit responsible for parsing and evaluating JavaScript code, and BridgeSupport, which enables libraries to expose the definition of their C structures and functions for use at run-time (as opposed to compile-time)."
  s.homepage     = "https://github.com/Ashton-W/Mocha"
  s.license      = {
    :type => 'Apache License, Version 2.0',
    :text => <<-LICENSE
              Copyright 2012 Logan Collins

              Licensed under the Apache License, Version 2.0 (the "License");
              you may not use this file except in compliance with the License.
              You may obtain a copy of the License at

                  http://www.apache.org/licenses/LICENSE-2.0

              Unless required by applicable law or agreed to in writing, software
              distributed under the License is distributed on an "AS IS" BASIS,
              WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
              See the License for the specific language governing permissions and
              limitations under the License.
    LICENSE
  }
  s.author       = { "Logan Collins" => "loganscollins@gmail.com" }
  s.source       = { :git => "https://github.com/Ashton-W/Mocha.git", :tag => s.version.to_s }
  s.platform = :ios
  s.ios.deployment_target = '5.0'
  s.source_files = 'Mocha/**/*.{h,m}', 'Mocha/*.{h,m}'
  s.public_header_files = 'Mocha/*(^_Private).h', 'Mocha/Objects/*(^_Private).h'
  s.frameworks  = 'Foundation'
  s.libraries = 'iOSJavaScriptCore', 'icucore', 'stdc++'
  s.requires_arc = true
  s.preferred_dependency = 'JavaScriptCore'

  s.subspec 'JavaScriptCore' do |js|
    js.source_files =  'libMocha (iOS)/JavaScriptCore/**/*.h'
    js.header_dir   =  'JavaScriptCore'
    js.header_mappings_dir = 'JavaScriptCore'
    js.libraries = 'iOSJavaScriptCore'
    js.dependency 'libffi', '~> 3.0.0'
  end
end
