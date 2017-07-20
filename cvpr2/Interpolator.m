//
//  InterpoQueue.m
//  marsvins
//
//  Created by Christopher Cobar on 8/3/16.
//  Copyright © 2016 marslab. All rights reserved.
//

#import "Interpolator.h"

@implementation Interpolator

- (instancetype)init {
    
    self = [super init];
    
    if (self) {
        
        self.accelQ = [[LinkedList alloc] init];
        self.gyroQ = [[LinkedList alloc] init];
        self.opLock = [[NSLock alloc] init];
        
        self.accel_semaphore = dispatch_semaphore_create(self.accelQ.size);
        self.gyro_semaphore = dispatch_semaphore_create(self.gyroQ.size);
        
    } else {
        
        self = nil;
        
    }
    
    return self;
    
}

- (void) GiveAccel:(AccelData *)accel {
    
    [[self opLock] lock];
    
    
    [self.accelQ addLast:accel];
    
    
    [[self opLock] unlock];

    dispatch_semaphore_signal(self.accel_semaphore);
    
}

- (void) GiveGyro:(GyroData *)gyro {
    
    [[self opLock] lock];
    
    
    [self.gyroQ addLast:gyro];
    
    
    [[self opLock] unlock];
    
    dispatch_semaphore_signal(self.gyro_semaphore);
    
}

- (IMUMeasurement *)interpolate {
    
    dispatch_semaphore_wait(self.accel_semaphore, DISPATCH_TIME_FOREVER);
    dispatch_semaphore_wait(self.gyro_semaphore, DISPATCH_TIME_FOREVER);
    dispatch_semaphore_wait(self.gyro_semaphore, DISPATCH_TIME_FOREVER);

    [self.opLock lock];
    
    int gsize = [[self gyroQ] size];
    int asize = [[self accelQ] size];
    
    if (gsize < 2 || asize < 1) {
        [self.opLock unlock];
        return nil;
    }
    
    AccelData *a1 = (AccelData *)((Node *)[[self accelQ] head]).data;
    GyroData *g1 = (GyroData *)((Node *)[[self gyroQ] head]).data;
    GyroData *g2 = (GyroData *)((Node *)((Node *)[[self gyroQ] head]).next).data;
    
    double a1Time = a1.timeStamp;
    double g1Time = g1.timeStamp;
    double g2Time = g2.timeStamp;
    
    if (g1Time < a1Time && g2Time < a1Time) {
        [[self gyroQ] pollFirst];
        [self.opLock unlock];
        dispatch_semaphore_signal(self.accel_semaphore);
        dispatch_semaphore_signal(self.gyro_semaphore);
        return nil;//return [self interpolate];
    }
    
    if (a1Time < g1Time && a1Time < g2Time) {
        [[self accelQ] pollFirst];
        [self.opLock unlock];
        dispatch_semaphore_signal(self.gyro_semaphore);
        dispatch_semaphore_signal(self.gyro_semaphore);
        return nil;//return [self interpolate];
    }
    
    
    double lambda = (a1Time - g1Time)/(g2Time - g1Time);
    
    double gx = ((1 - lambda) * g1.rotationX) + (lambda * g2.rotationX);
    
    double gy = ((1 - lambda) * g1.rotationY) + (lambda * g2.rotationY);
    
    double gz = ((1 - lambda) * g1.rotationZ) + (lambda * g2.rotationZ);
    
    GyroData *gyroOut = [[GyroData alloc] init:a1Time X:gx Y:gy Z:gz];
    
    IMUMeasurement *imuMeas = [[IMUMeasurement alloc] init:a1Time gyro:gyroOut accel:a1];
    
    [[self accelQ] pollFirst];
    
    [self.opLock unlock];
    
    dispatch_semaphore_signal(self.gyro_semaphore);
    dispatch_semaphore_signal(self.gyro_semaphore);
    
    return imuMeas;
    
}

@end
