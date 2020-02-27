// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 27/02/20.
//  All code (c) 2020 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation
import AppKit
import Sparkle

@objc class Plugin: NSResponder, SparkleBridgePlugin, SPUUpdaterDelegate {
    var driver: BridgingDriver!
    var updater: SPUUpdater!

    func setup(with bridge: SparkleBridge) {
        let hostBundle = Bundle.main
        driver = BridgingDriver(wrapping: bridge)
        updater = SPUUpdater(hostBundle: hostBundle, applicationBundle: hostBundle, userDriver: driver, delegate: self)
        do {
            try updater.start()
        } catch {
            // handle error
        }
    }
}
