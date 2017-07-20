//
//  FramePacket.m
//  cvpr2
//
//  Created by Christopher Cobar on 7/12/17.
//  Copyright © 2017 christophercobar. All rights reserved.
//

#import "FramePacket.h"

@implementation FramePacket

- (instancetype)init: (unsigned char *) frame
                   t: (double) timestamp {
    
    self = [super init];
    
    if (self) {
        
        self.frame = frame;
        self.timestamp = timestamp;
        
    } else {
        
        self = nil;
        
    }
    
    return self;
    
}

@end
