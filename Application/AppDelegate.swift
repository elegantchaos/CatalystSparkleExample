// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 27/02/20.
//  All code (c) 2020 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import UIKit
import SparkleBridgeClient

@UIApplicationMain

class AppDelegate: UIResponder, UIApplicationDelegate {
    var plugin: SparkleBridgePlugin?
    var testServer: TestServerPlugin?
    var driver: CatalystSparkleDriver!
    
    class var shared: AppDelegate {
        return UIApplication.shared.delegate as! AppDelegate
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        driver = CatalystSparkleDriver()
        let result = SparkleBridgeClient.load(with: driver)
        switch result {
            case .success(let plugin):
                self.plugin = plugin
            case .failure(let error):
                print(error)
        }
        
        loadTestServer()
        return true
    }
    
    // MARK: UISceneSession Lifecycle
    
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
    fileprivate func loadTestServer() {
        if let pluginURL = Bundle.main.url(forResource: "TestServer", withExtension: "bundle"), let bundle = Bundle(url: pluginURL) {
            if let cls = bundle.principalClass as? NSObject.Type {
                if let instance = cls.init() as? TestServerPlugin {
                    testServer = instance
                    testServer?.setup()
                }
            }
        }
    }
    
}

