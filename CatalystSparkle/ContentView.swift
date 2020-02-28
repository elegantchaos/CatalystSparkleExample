// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 27/02/20.
//  All code (c) 2020 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import SwiftUI

struct ContentView: View {
    @ObservedObject var driver: CatalystSparkleDriver
    
    var body: some View {
        VStack(spacing: 8) {
            if AppDelegate.shared.plugin == nil {
                Text("Sparkle failed to start up: \(String(describing: driver.setupError))")
            } else if AppDelegate.shared.testServer == nil {
                Text("Test server failed to start up.")
            } else {
                VStack {
                    Text("Sparkle bridge working.")
                    
                    if driver.canCheck {
                        Text("Can check for updates.")
                    }
                    
                    if !driver.status.isEmpty {
                        Text("Sparkle Status: \(driver.status)")
                    }
                    
                    Button(action: { AppDelegate.shared.plugin?.checkForUpdates() }) {
                        Text("Check")
                    }
                }
            }
            
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(driver: CatalystSparkleDriver())
    }
}
