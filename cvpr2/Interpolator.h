//
//  InterpoQueue.h
//  marsvins
//
//  Created by Christopher Cobar on 8/3/16.
//  Copyright © 2016 marslab. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AccelData.h"
#import "GyroData.h"
#import "IMUMeasurement.h"
#import "LinkedList.h"
#include <semaphore.h>

@interface Interpolator : NSObject

@property (nonatomic) LinkedList *accelQ;

@property (nonatomic) LinkedList *gyroQ;

@property (nonatomic) NSLock *opLock;

//https://developer.apple.com/library/ios/documentation/General/Conceptual/ConcurrencyProgrammingGuide/OperationQueues/OperationQueues.html
@property (nonatomic) dispatch_semaphore_t accel_semaphore;

@property (nonatomic) dispatch_semaphore_t gyro_semaphore;

- (instancetype)init;

// returns interpolated IMU measurement based on most recent accelQ and
// gyroQ samplings
- (IMUMeasurement *)interpolate;
- (void) GiveAccel: (AccelData *) accel;
- (void) GiveGyro: (GyroData *) gyro;

@end
