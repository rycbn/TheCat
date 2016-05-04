//
//  Utilities.m
//  TheCat
//
//  Created by Roger Yong on 04/05/2016.
//  Copyright © 2016 rycbn. All rights reserved.
//

#import "Utilities.h"

@implementation Utilities

+ (BOOL)hasCellularCoverage {
    CTTelephonyNetworkInfo *telephoneNetworkInfo = [CTTelephonyNetworkInfo new];
    CTCarrier *carrier = [telephoneNetworkInfo subscriberCellularProvider];
    CTSubscriber *subcriber = [CTSubscriber new];
    
    if (!carrier.mobileNetworkCode) {
        return NO;
    }
    if (!subcriber.carrierToken) {
        return NO;
    }
    return YES;
}

+ (void)displayAlertWithTitle:(NSString *)title message:(NSString *)message viewController:(UIViewController *)viewController {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title
                                                                             message:message
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK"
                                                       style:UIAlertActionStyleDefault
                                                     handler:nil];
    [alertController addAction:okAction];
    [viewController presentViewController:alertController animated:true completion:nil];
}

@end
