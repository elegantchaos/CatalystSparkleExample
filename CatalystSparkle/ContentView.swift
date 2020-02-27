// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 27/02/20.
//  All code (c) 2020 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import SwiftUI

struct ContentView: View {
    @ObservedObject var driver: CatalystSparkleDriver
    
    var body: some View {
        VStack {
            if driver.canCheck {
                Text("Sparkle bridge working.")
            } else {
                Text("Sparkle failed to start up: \(String(describing: driver.setupError))")
            }
            if !driver.status.isEmpty {
                Text("Sparkle Status: \(driver.status)")
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(driver: CatalystSparkleDriver())
    }
}
