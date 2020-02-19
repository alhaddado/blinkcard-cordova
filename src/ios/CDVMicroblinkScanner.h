#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <Cordova/CDV.h>


@interface CDVMicroblinkScanner : CDVPlugin

- (void)read:(CDVInvokedUrlCommand *)command;

- (void)returnResults:(NSArray *)results cancelled:(BOOL)cancelled;

- (void)returnError:(NSString *)message;

@end
