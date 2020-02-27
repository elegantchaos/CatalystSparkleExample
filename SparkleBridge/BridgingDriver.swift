// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 27/02/20.
//  All code (c) 2020 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation
import Sparkle

/// Sparkle Driver which forwards all messages on to a bridge object.
///
/// The bridge straddles the Obj-C/Swift barrier, and implements an
/// Objective-C protocol, so it doesn't:
/// - use native Swift types
/// - expose Sparkle types
///
/// As a result, it has to do some minor conversion of data in both
/// directions. In theory it also sacrifices a bit of type safety,
/// although in this example it is added back on the other side
/// of the fence.

internal class BridgingDriver: NSObject, SPUUserDriver {
    let driver: SparkleBridge

    init(wrapping driver: SparkleBridge) {
        self.driver = driver
    }
    
    func showCanCheck(forUpdates canCheckForUpdates: Bool) {
        driver.showCanCheck(forUpdates: canCheckForUpdates)
    }
    
    func show(_ request: SPUUpdatePermissionRequest, reply: @escaping (SUUpdatePermissionResponse) -> Void) {
        driver.showUpdatePermissionRequest(request.systemProfile) { response in
            reply(SUUpdatePermissionResponse(response))
        }
    }
    
    func showUserInitiatedUpdateCheck(completion updateCheckStatusCompletion: @escaping (SPUUserInitiatedCheckStatus) -> Void) {
        driver.showUserInitiatedUpdateCheck() { status in
            updateCheckStatusCompletion(SPUUserInitiatedCheckStatus(rawValue: status)!)
        }
    }
    
    func dismissUserInitiatedUpdateCheck() {
        driver.dismissUserInitiatedUpdateCheck()
    }
    
    func showUpdateFound(with appcastItem: SUAppcastItem, userInitiated: Bool, reply: @escaping (SPUUpdateAlertChoice) -> Void) {
        driver.showUpdateFound(withAppcastItem: appcastItem.propertiesDictionary, userInitiated: userInitiated) { choice in
            reply(SPUUpdateAlertChoice(rawValue: choice)!)
        }
    }
    
    func showDownloadedUpdateFound(with appcastItem: SUAppcastItem, userInitiated: Bool, reply: @escaping (SPUUpdateAlertChoice) -> Void) {
        driver.showDownloadedUpdateFound(withAppcastItem: appcastItem.propertiesDictionary, userInitiated: userInitiated) { choice in
            reply(SPUUpdateAlertChoice(rawValue: choice)! )
        }
    }
    
    func showResumableUpdateFound(with appcastItem: SUAppcastItem, userInitiated: Bool, reply: @escaping (SPUInstallUpdateStatus) -> Void) {
        driver.showResumableUpdateFound(withAppcastItem: appcastItem.propertiesDictionary, userInitiated: userInitiated) { choice in
            reply(SPUInstallUpdateStatus(rawValue: choice)!)
        }
    }
    
    func showInformationalUpdateFound(with appcastItem: SUAppcastItem, userInitiated: Bool, reply: @escaping (SPUInformationalUpdateAlertChoice) -> Void) {
        driver.showInformationalUpdateFound(withAppcastItem: appcastItem.propertiesDictionary, userInitiated: userInitiated) { choice in
            reply(SPUInformationalUpdateAlertChoice(rawValue: choice)!)
        }
    }
    
    func showUpdateReleaseNotes(with downloadData: SPUDownloadData) {
        driver.showUpdateReleaseNotes(withDownloadData: downloadData.data, encoding: downloadData.textEncodingName, mimeType: downloadData.mimeType)
    }
    
    func showUpdateReleaseNotesFailedToDownloadWithError(_ error: Error) {
        driver.showUpdateReleaseNotesFailedToDownloadWithError(error)
    }
    
    func showUpdateNotFound(acknowledgement: @escaping () -> Void) {
        driver.showUpdateNotFound {
            acknowledgement()
        }
    }
    
    func showUpdaterError(_ error: Error, acknowledgement: @escaping () -> Void) {
        driver.showUpdaterError(error) {
            acknowledgement()
        }
    }
    
    func showDownloadInitiated(completion downloadUpdateStatusCompletion: @escaping (SPUDownloadUpdateStatus) -> Void) {
        driver.showDownloadInitiated() { status in
            downloadUpdateStatusCompletion(SPUDownloadUpdateStatus(rawValue: status)!)
        }
    }
    
    func showDownloadDidReceiveExpectedContentLength(_ expectedContentLength: UInt64) {
        driver.showDownloadDidReceiveExpectedContentLength(expectedContentLength)
    }
    
    func showDownloadDidReceiveData(ofLength length: UInt64) {
        driver.showDownloadDidReceiveData(ofLength: length)
    }
    
    func showDownloadDidStartExtractingUpdate() {
        driver.showDownloadDidStartExtractingUpdate()
    }
    
    func showExtractionReceivedProgress(_ progress: Double) {
        driver.showExtractionReceivedProgress(progress)
    }
    
    func showReady(toInstallAndRelaunch installUpdateHandler: @escaping (SPUInstallUpdateStatus) -> Void) {
        driver.showReady() { status in
            installUpdateHandler(SPUInstallUpdateStatus(rawValue: status)!)
        }
    }
    
    func showInstallingUpdate() {
        driver.showInstallingUpdate()
    }
    
    func showSendingTerminationSignal() {
        driver.showSendingTerminationSignal()
    }
    
    func showUpdateInstallationDidFinish(acknowledgement: @escaping () -> Void) {
        driver.showUpdateInstallationDidFinish() { acknowledgement() }
    }
    
    func dismissUpdateInstallation() {
        driver.dismissUpdateInstallation()
    }
}

extension SUUpdatePermissionResponse {
    convenience init(_ bridged: SparkleBridgeUpdatePermissionResponse) {
        self.init(automaticUpdateChecks: bridged.automaticUpdateChecks.boolValue, sendSystemProfile: bridged.sendSystemProfile.boolValue)
    }
}

