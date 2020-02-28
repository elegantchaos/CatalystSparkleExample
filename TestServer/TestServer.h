// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Developer on 27/02/2020.
//  All code (c) 2020 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

#import <Foundation/Foundation.h>

@protocol TestServerPlugin
- (void)setup;
- (void)tearDown;
@end

@interface TestServer : NSObject<TestServerPlugin>
- (void)setup;
- (void)tearDown;
@end
