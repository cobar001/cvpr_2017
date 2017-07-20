//
//  Node.m
//  marsvins
//
//  Created by Christopher Cobar on 8/4/16.
//  Copyright © 2016 marslab. All rights reserved.
//

#import "Node.h"

@implementation Node

- (instancetype)init: (id) object
                   n: (Node *) next
                prev: (Node *) previous {
    
    self = [super init];
    
    if (self) {
        
        self.data = object;
        self.next = next;
        self.previous = previous;
        
    } else {
        
        self = nil;
        
    }
    
    return self;
    
}


@end
