//
//  AccelData.m
//  marsvins
//
//  Created by Christopher Cobar on 8/3/16.
//  Copyright © 2016 marslab. All rights reserved.
//

#import "AccelData.h"

@implementation AccelData

- (instancetype)init: (double) timeStamp
                   X: (double) accelerationX
                   Y: (double) accelerationY
                   Z: (double) accelerationZ {
    
    self = [super init];
    
    if (self) {
        
        self.timeStamp = timeStamp;
        self.accelerationX = accelerationX;
        self.accelerationY = accelerationY;
        self.accelerationZ = accelerationZ;
        
    } else {
        
        self = nil;
        
    }
    
    return self;
    
}

- (NSString *)toString {
    
    return [NSString stringWithFormat:@"%f %f %f %f", self.timeStamp, self.accelerationX, self.accelerationY, self.accelerationZ];
    
}

@end
