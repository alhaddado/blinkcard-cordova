#import "CDVMicroblinkScanner.h"
#import <Microblink/Microblink.h>

@interface CDVPlugin () <MBBlinkCardOverlayViewControllerDelegate>

@property (nonatomic, retain) CDVInvokedUrlCommand *lastCommand;

@end

@interface CDVMicroblinkScanner ()

@property (nonatomic, nonnull) MBBlinkCardRecognizer *blinkCardRecognizer;

@end

@implementation CDVMicroblinkScanner

@synthesize lastCommand;

/**
 Method  sanitizes the dictionary replaces all occurances of NSNull with nil

 @param dictionary JSON objects
 @return new dictionary with NSNull values replaced with nil
*/
- (NSDictionary *)sanitizeDictionary:(NSDictionary *)dictionary {
    NSMutableDictionary *mutableDictionary = [[NSMutableDictionary alloc] initWithDictionary:dictionary];
    for (NSString* key in dictionary.allKeys) {
        if (mutableDictionary[key] == [NSNull null]) {
            mutableDictionary[key] = nil;
        }
    }
    return mutableDictionary;
}

#pragma mark - Main


- (void)read:(CDVInvokedUrlCommand *)command {

    [self setLastCommand:command];

    NSDictionary *settings = [self sanitizeDictionary:[self.lastCommand argumentAtIndex:0]];

    [[MBMicroblinkSDK sharedInstance] setLicenseKey:[settings objectForKey:@"iosKey"]];

    self.blinkCardRecognizer = [[MBBlinkCardRecognizer alloc] init];
    self.blinkCardRecognizer.extractCvv = [settings objectForKey:@"Cvv"];
    self.blinkCardRecognizer.returnFullDocumentImage = [settings objectForKey:@"returnFullDocumentImage"];

    MBRecognizerCollection *recognizerCollection = [[MBRecognizerCollection alloc] initWithRecognizers:@[self.blinkCardRecognizer]];
    MBBlinkCardOverlaySettings *overlaySettings = [[MBBlinkCardOverlaySettings alloc] init];

    MBBlinkCardOverlayViewController *blinkCardOveralyViewController = [[MBBlinkCardOverlayViewController alloc] initWithSettings:overlaySettings recognizerCollection:recognizerCollection delegate:self];

    UIViewController<MBRecognizerRunnerViewController>* recognizerRunnerViewController = [MBViewControllerFactory recognizerRunnerViewControllerWithOverlayViewController:blinkCardOveralyViewController];

    [[self viewController] presentViewController:recognizerRunnerViewController animated:YES completion:nil];
}

- (void)blinkCardOverlayViewControllerDidFinishScanning:(nonnull MBBlinkCardOverlayViewController *)blinkCardOverlayViewController state:(MBRecognizerResultState)state {

    [blinkCardOverlayViewController.recognizerRunnerViewController pauseScanning];

    NSString *title;
    NSString *message;

    if (self.blinkCardRecognizer.result.resultState == MBRecognizerResultStateValid) {
        title = @"Payment card";

        UIImage *fullDocumentImage = self.blinkCardRecognizer.result.fullDocumentFrontImage.image;
        NSLog(@"Got payment card image with width: %f, height: %f", fullDocumentImage.size.width, fullDocumentImage.size.height);
        message = self.blinkCardRecognizer.result.description;
    }

    NSDictionary *resultDict = @{
       @"cardNumber" : self.blinkCardRecognizer.result.cardNumber,
       @"cardCvv" : self.blinkCardRecognizer.result.cvv,
       @"cardOwner" : self.blinkCardRecognizer.result.owner,
       @"cardExpDate" : self.blinkCardRecognizer.result.validThru.originalDateString
    };

    CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:resultDict];

    [self.commandDelegate sendPluginResult:result callbackId:self.lastCommand.callbackId];

    // dismiss recognizer runner view controller
    dispatch_async(dispatch_get_main_queue(), ^{
        [[self viewController] dismissViewControllerAnimated:YES completion:nil];
    });

}

- (void)blinkCardOverlayViewControllerDidTapClose:(nonnull MBBlinkCardOverlayViewController *)blinkCardOverlayViewController {
    [blinkCardOverlayViewController dismissViewControllerAnimated:YES completion:nil];
}


@end
