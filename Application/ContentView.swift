// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 27/02/20.
//  All code (c) 2020 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import SwiftUI
import SparkleBridgeClient

struct ContentView: View {
    @ObservedObject var driver: CatalystSparkleDriver
    
    var body: some View {
        VStack(spacing: 10) {
            Spacer()

            if AppDelegate.shared.plugin == nil {
                Text("Sparkle failed to start up: \(String(describing: driver.setupError))")
            } else {
                Text("Sparkle bridge connected.")
            }
            
            if AppDelegate.shared.testServer == nil {
                Text("Test server failed to start up.")
            } else {
                Text("Test server connected.")
            }
            
            Spacer().frame(height: 20)

            if !driver.status.isEmpty {
                Text(driver.status).font(.headline)
            }
            
            Spacer()
            
            if driver.hasBeenUpdated {
                Text("This Is The Updated Version!").font(.largeTitle)
            } else {
                ButtonViews(driver: driver)
            }
            
        }.padding()
    }
}

struct ButtonViews: View {
    @ObservedObject var driver: CatalystSparkleDriver

    var body: some View {
        VStack {
            
          if driver.canCheck {
              Button(action: { AppDelegate.shared.plugin?.checkForUpdates() }) {
                  Text("Check For Updates")
              }
          }
          
          if driver.updateCallback != nil {
              DownloadView(driver: driver)
          }
          
          if driver.installCallback != nil {
              InstallView(driver: driver)
          }
          
          if driver.okCallback != nil {
              Button(action: {
                  self.driver.okCallback?()
                  self.driver.okCallback = nil
              }) {
                  Text("OK")
              }
          }
        }
    }
}
struct DownloadView: View {
    @ObservedObject var driver: CatalystSparkleDriver
    
    var body: some View {
        HStack {
            Button(action: driver.downloadUpdate) { Text("Update") }
            Button(action: driver.skipUpdate) { Text("Skip") }
            Button(action: driver.ignoreUpdate) { Text("Later") }
        }
    }
}

struct InstallView: View {
    @ObservedObject var driver: CatalystSparkleDriver
    
    var body: some View {
        HStack {
            Button(action: driver.installUpdate) { Text("Install And Restart") }
        }
    }
}
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(driver: CatalystSparkleDriver())
    }
}
