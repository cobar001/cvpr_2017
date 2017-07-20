//
//  AccelData.h
//  marsvins
//
//  Created by Christopher Cobar on 8/3/16.
//  Copyright © 2016 marslab. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AccelData : NSObject

@property (nonatomic) double timeStamp;

@property (nonatomic) double accelerationX;

@property (nonatomic) double accelerationY;

@property (nonatomic) double accelerationZ;

- (instancetype)init: (double) timeStamp
                   X: (double) accelerationX
                   Y: (double) accelerationY
                   Z: (double) accelerationZ;

- (NSString *)toString;

@end
