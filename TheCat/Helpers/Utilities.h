//
//  Utilities.h
//  TheCat
//
//  Created by Roger Yong on 04/05/2016.
//  Copyright © 2016 rycbn. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <CoreTelephony/CTCarrier.h>
#import <CoreTelephony/CTSubscriber.h>

@interface Utilities : NSObject

+ (BOOL)hasCellularCoverage;
+ (void)displayAlertWithTitle:(NSString *)title message:(NSString *)message viewController:(UIViewController *)viewController;

@end
