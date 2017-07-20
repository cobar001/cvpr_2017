//
//  AccelGyroMeasurement.h
//  marsvins
//
//  Created by Christopher Cobar on 8/4/16.
//  Copyright © 2016 marslab. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GyroData.h"
#import "AccelData.h"

@interface IMUMeasurement : NSObject

@property (nonatomic) double timeStamp;

@property (nonatomic) GyroData *gyroMeasurement;

@property (nonatomic) AccelData *accelMeasurement;

- (instancetype)init: (double) timeStamp
                gyro: (GyroData *) gyroMeasurement
               accel: (AccelData *) accelMeasurement;

- (NSString *)toString;

@end
