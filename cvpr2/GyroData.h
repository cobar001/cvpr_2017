//
//  GyroData.h
//  marsvins
//
//  Created by Christopher Cobar on 8/3/16.
//  Copyright © 2016 marslab. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GyroData : NSObject

@property (nonatomic) double timeStamp;

@property (nonatomic) double rotationX;

@property (nonatomic) double rotationY;

@property (nonatomic) double rotationZ;

- (instancetype)init: (double) timeStamp
                   X: (double) rotationX
                   Y: (double) rotationY
                   Z: (double) rotationZ;

- (NSString *)toString;

@end
