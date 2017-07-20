//
//  FramePacket.h
//  cvpr2
//
//  Created by Christopher Cobar on 7/12/17.
//  Copyright © 2017 christophercobar. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IMUMeasurement.h"
#include <vector>

@interface FramePacket : NSObject

@property (nonatomic) unsigned char *frame;
@property (nonatomic) int frameWidth;
@property (nonatomic) int frameHeight;
@property (nonatomic) std::vector<double> imuFrame;
@property (nonatomic) double timestamp;
@property (nonatomic) size_t bufferSize;

- (instancetype)init: (unsigned char *) frame
                   t: (double) timestamp;

@end
