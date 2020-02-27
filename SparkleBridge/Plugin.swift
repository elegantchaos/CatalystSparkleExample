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
    var tester: Tester?
    
    func setup(with bridge: SparkleBridge) throws {
        let hostBundle = Bundle.main
        driver = BridgingDriver(wrapping: bridge)
        updater = SPUUpdater(hostBundle: hostBundle, applicationBundle: hostBundle, userDriver: driver, delegate: self)
        try updater.start()
    }
    
    func setupTester() {
        tester = Tester()
        tester?.setup()
    }
    
    func tearDownTester() {
        tester?.tearDown()
        tester = nil
    }
}
