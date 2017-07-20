//
//  GyroData.m
//  marsvins
//
//  Created by Christopher Cobar on 8/3/16.
//  Copyright © 2016 marslab. All rights reserved.
//

#import "GyroData.h"

@implementation GyroData

- (instancetype)init: (double) timeStamp
                   X: (double) rotationX
                   Y: (double) rotationY
                   Z: (double) rotationZ {
    
    self = [super init];
    
    if (self) {
        
        self.timeStamp = timeStamp;
        self.rotationX = rotationX;
        self.rotationY = rotationY;
        self.rotationZ = rotationZ;
        
        
    } else {
        
        self = nil;
        
    }
    
    return self;
    
}

- (NSString *)toString {
    
    return [NSString stringWithFormat:@"%f %f %f %f", self.timeStamp, self.rotationX, self.rotationY, self.rotationZ];
    
}


@end
