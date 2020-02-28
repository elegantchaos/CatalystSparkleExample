// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 27/02/20.
//  All code (c) 2020 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef struct {
    BOOL automaticUpdateChecks;
    BOOL sendSystemProfile;
} SparkleBridgeUpdatePermissionResponse;

@protocol SparkleBridge <NSObject>
- (void)showCanCheckForUpdates:(BOOL)canCheckForUpdates;
- (void)showUpdatePermissionRequest:(NSArray<NSDictionary<NSString *, NSString *> *> *)request reply:(void (^)(SparkleBridgeUpdatePermissionResponse))reply;
- (void)showUserInitiatedUpdateCheckWithCompletion:(void (^)(NSUInteger))updateCheckStatusCompletion;
- (void)dismissUserInitiatedUpdateCheck;
- (void)showUpdateFoundWithAppcastItem:(NSDictionary *)appcastItem userInitiated:(BOOL)userInitiated reply:(void (^)(NSInteger))reply;
- (void)showDownloadedUpdateFoundWithAppcastItem:(NSDictionary *)appcastItem userInitiated:(BOOL)userInitiated reply:(void (^)(NSInteger))reply;
- (void)showResumableUpdateFoundWithAppcastItem:(NSDictionary *)appcastItem userInitiated:(BOOL)userInitiated reply:(void (^)(NSUInteger))reply;
- (void)showInformationalUpdateFoundWithAppcastItem:(NSDictionary *)appcastItem userInitiated:(BOOL)userInitiated reply:(void (^)(NSInteger))reply;
- (void)showUpdateReleaseNotesWithDownloadData:(NSData *)downloadData encoding: (nullable NSString *) encoding mimeType: (nullable NSString *) mimeType;
- (void)showUpdateReleaseNotesFailedToDownloadWithError:(NSError *)error;
- (void)showUpdateNotFoundWithAcknowledgement:(void (^)(void))acknowledgement;
- (void)showUpdaterError:(NSError *)error acknowledgement:(void (^)(void))acknowledgement;
- (void)showDownloadInitiatedWithCompletion:(void (^)(NSUInteger))downloadUpdateStatusCompletion;
- (void)showDownloadDidReceiveExpectedContentLength:(uint64_t)expectedContentLength;
- (void)showDownloadDidReceiveDataOfLength:(uint64_t)length;
- (void)showDownloadDidStartExtractingUpdate;
- (void)showExtractionReceivedProgress:(double)progress;
- (void)showReadyToInstallAndRelaunch:(void (^)(NSUInteger))installUpdateHandler;
- (void)showInstallingUpdate;
- (void)showSendingTerminationSignal;
- (void)showUpdateInstallationDidFinishWithAcknowledgement:(void (^)(void))acknowledgement;
- (void)dismissUpdateInstallation;
@end

@protocol SparkleBridgePlugin <NSObject>
- (BOOL)setupWithBridge: (id<SparkleBridge>)bridge error:(NSError **)error;
- (void)checkForUpdates;
@end

NS_ASSUME_NONNULL_END
