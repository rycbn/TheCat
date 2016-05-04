//
//  NSDictionary+TheCatPackage.m
//  TheCat
//
//  Created by Roger Yong on 04/05/2016.
//  Copyright © 2016 rycbn. All rights reserved.
//

#import "NSDictionary+TheCatPackage.h"

@implementation NSDictionary (TheCatPackage)

- (NSArray *)upcomingCat {
    NSDictionary *dictionary = self[@"images"];
    return dictionary[@"image"];
}

- (NSString *)imageUrl {
    NSString *urlString = self[@"url"];
    return urlString;
}

@end
