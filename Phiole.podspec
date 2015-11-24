Pod::Spec.new do |s|

  # ―――  Spec Metadata  ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #

  s.name         = "Phiole"
  s.version      = "1.0.0"
  s.summary      = "Allow to write or read from standards stream in swift"

  s.description  = <<-DESC
                   Simple object to wrap three NSFileHandle: 'output', 'error' to write and 'input' to read

                   This object could be used in script or CLI application instead of using `print()`.
                   This adds the following abilities :
                   * Write to a file by declaring transparently an [NSFileHandle](https://developer.apple.com/library/mac/documentation/Cocoa/Reference/Foundation/Classes/NSFileHandle_Class/index.html) as output stream
                   * Write to error stream
                   * Read from input stream
                   DESC

  s.homepage     = "https://github.com/phimage/Phiole"


  # ―――  Spec License  ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #

  s.license      = "MIT (Eric Marchand)"


  # ――― Author Metadata  ――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #

  s.author             = "Eric Marchand (phimage)"

  # ――― Platform Specifics ――――――――――――――――――――――――――――――――――――――――――――――――――――――― #

  s.ios.deployment_target = "8.0"
  s.osx.deployment_target = "10.9"

  # ――― Source Location ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #

  s.source       = { :git => "https://github.com/phimage/Phiole.git", :tag => s.version  }

  # ――― Source Code ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #

  s.source_files  = "*.swift"

  # ――― Resources ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #

  s.resource  = "logo-128x128.png"

  # ――― Project Linking ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #

  # ――― Project Settings ――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #

end
