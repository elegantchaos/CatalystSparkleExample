// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Developer on 27/02/2020.
//  All code (c) 2020 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

class CatalystSparkleDriver: SparkleDriver, ObservableObject {
    var setupError: NSError?
    var updateCallback: UpdateAlertCallback?
    var canCheck = false
    
    var expected: UInt64 = 0 {
        didSet {
            progress = expected > 0 ? Double(received)/Double(expected) : 0
        }
    }
    var received: UInt64 = 0 {
        didSet {
            progress = expected > 0 ? Double(received)/Double(expected) : 0
        }
    }
    
    var percent: Int {
        return Int(progress * 100)
    }
    
    @Published var progress: Double = 0
    @Published var status: String = ""
    
    var hasUpdate: Bool {
        return updateCallback != nil
    }
    
    func installUpdate() {
        updateCallback?(.update)
        updateCallback = nil
    }
    
    func skipUpdate() {
        updateCallback?(.skip)
        updateCallback = nil
    }
    
    func ignoreUpdate() {
        updateCallback?(.later)
        updateCallback = nil
    }
    
    override func showCanCheck(forUpdates canCheckForUpdates: Bool) {
        print("canCheckForUpdates: \(canCheckForUpdates)")
        canCheck = canCheckForUpdates
    }
    
    override func showUpdatePermissionRequest(_ request: UpdatePermissionRequest, reply: @escaping (UpdatePermissionResponse) -> Void) {
        print("show")
    }
    
    override func showUserInitiatedUpdateCheck(completion updateCheckStatusCompletion: @escaping (UserInitiatedCheckStatus) -> Void) {
        print("showUserInitiatedUpdateCheck")
        status = "Checking for update."
    }
    
    override func dismissUserInitiatedUpdateCheck() {
        print("dismissUserInitiatedUpdateCheck")
        status = ""
    }
    
    override func showUpdateFound(with appcastItem: AppcastItem, userInitiated: Bool, reply: @escaping UpdateAlertCallback) {
        print("showUpdateFound")
        status = "Update available."
        updateCallback = reply
    }
    
    override func showDownloadedUpdateFound(with appcastItem: AppcastItem, userInitiated: Bool, reply: @escaping UpdateAlertCallback) {
        print("showDownloadedUpdateFound")
    }
    
    override func showResumableUpdateFound(with appcastItem: AppcastItem, userInitiated: Bool, reply: @escaping UpdateStatusCallback) {
        print("showResumableUpdateFound")
    }
    
    override func showInformationalUpdateFound(with appcastItem: AppcastItem, userInitiated: Bool, reply: @escaping InformationCallback) {
        print("showInformationalUpdateFound")
    }
    
    override func showUpdateReleaseNotes(withDownloadData downloadData: Data, encoding: String?, mimeType: String?) { 
        print("showUpdateReleaseNotes")
    }
    
    override func showUpdateReleaseNotesFailedToDownloadWithError(_ error: Error) {
        print("showUpdateReleaseNotesFailedToDownloadWithError")
    }
    
    override func showUpdateNotFound(acknowledgement: @escaping () -> Void) {
        print("showUpdaterError")
    }
    
    override func showUpdaterError(_ error: Error, acknowledgement: @escaping () -> Void) {
        print("showUpdaterError")
        status = "Failed to launch installer."
    }
    
    override func showDownloadInitiated(completion downloadUpdateStatusCompletion: @escaping DownloadStatusCallback) {
        print("showDownloadInitiated")
        status = "Downloading update..."
    }
    
    override func showDownloadDidReceiveExpectedContentLength(_ expectedContentLength: UInt64) {
        print("showDownloadDidReceiveExpectedContentLength")
        expected = expectedContentLength
    }
    
    override func showDownloadDidReceiveData(ofLength length: UInt64) {
        print("showDownloadDidReceiveData")
        received += length
        status = "Downloading update... (\(percent)%)"
    }
    
    override func showDownloadDidStartExtractingUpdate() {
        print("showDownloadDidStartExtractingUpdate")
        status = "Extracting update..."
    }
    
    override func showExtractionReceivedProgress(_ progress: Double) {
        print("showExtractionReceivedProgress")
        self.progress = progress
        status = "Extracting update... (\(percent)%)"
    }
    
    override func showReady(toInstallAndRelaunch installUpdateHandler: @escaping UpdateStatusCallback) {
        print("showReady")
        status = "Restarting..."
        installUpdateHandler(.installAndRelaunch)
    }
    
    override func showInstallingUpdate() {
        print("showInstallingUpdate")
        status = "Installing update..."
    }
    
    override func showSendingTerminationSignal() {
        print("showSendingTerminationSignal")
        status = "Sending termination..."
    }
    
    override func showUpdateInstallationDidFinish(acknowledgement: @escaping () -> Void) {
        print("showUpdateInstallationDidFinish")
        status = "Installation finished."
    }
    
    override func dismissUpdateInstallation() {
        print("dismissUpdateInstallation")
        status = ""
    }
    
    
}
