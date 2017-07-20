//
//  Node.h
//  marsvins
//
//  Created by Christopher Cobar on 8/4/16.
//  Copyright © 2016 marslab. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Node : NSObject

@property (nonatomic) id data;

@property (nonatomic) Node *next;

@property (nonatomic) Node *previous;

- (instancetype)init: (id) object
                   n: (Node *) next
                prev: (Node *) previous;

@end
