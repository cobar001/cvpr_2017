//
//  AccelGyroMeasurement.m
//  marsvins
//
//  Created by Christopher Cobar on 8/4/16.
//  Copyright © 2016 marslab. All rights reserved.
//

#import "IMUMeasurement.h"

@implementation IMUMeasurement

- (instancetype)init: (double) timeStamp
                gyro: (GyroData *) gyroMeasurement
               accel: (AccelData *) accelMeasurement {
    
    self = [super init];
    
    if (self) {
        
        self.timeStamp = timeStamp;
        self.gyroMeasurement = gyroMeasurement;
        self.accelMeasurement = accelMeasurement;
        
    } else {
        
        self = nil;
        
    }
    
    return self;
    
}

/*
- (GyroData *)gyroR: (GyroData *)gyro {
    
    
    
}

- (AccelData *)accelR: (AccelData *)accel {
    
    
    
}
*/

//altered output to account for transformation
- (NSString *)toString {
    
    return [NSString stringWithFormat:@"%f 0 %f %f %f %f %f %f 0 0 0",
            self.timeStamp,
            self.gyroMeasurement.rotationY * -1,
            self.gyroMeasurement.rotationX * -1,
            self.gyroMeasurement.rotationZ * -1,
            self.accelMeasurement.accelerationY,
            self.accelMeasurement.accelerationX,
            self.accelMeasurement.accelerationZ];
    
}

@end
