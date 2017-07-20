//
//  LinkedList.h
//  marsvins
//
//  Created by Christopher Cobar on 8/4/16.
//  Copyright © 2016 marslab. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Node.h"

@interface LinkedList : NSObject

@property (nonatomic) Node *head;

@property (nonatomic) Node *last;

@property (nonatomic) int size;

@property (nonatomic) NSLock* operationLock;


//initialize empty list
- (instancetype)init;

//add element to beginning of list
- (void)addFirst: (id)object;

//add element to end of list
- (void)addLast: (id)object;

//returns and removes head of list
- (Node *)pollFirst;

//returns and removes last element of list
- (Node *)pollLast;

//return array of first two
//- (NSArray *)pollFirstTwo;

@end
