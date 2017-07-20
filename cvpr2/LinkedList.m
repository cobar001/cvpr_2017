//
//  LinkedList.m
//  marsvins
//
//  Created by Christopher Cobar on 8/4/16.
//  Copyright © 2016 marslab. All rights reserved.
//

#import "LinkedList.h"


@implementation LinkedList

- (instancetype)init {
    
    self = [super init];
    
    if (self) {
        
        self.head = nil;
        self.last = nil;
        self.size = 0;
        
    } else {
        
        self = nil;
        
    }
    
    return self;
    
}

- (void)addFirst:(id)object {
    
    Node *n = [[Node alloc] init:object n:nil prev:nil];
    Node *temp;
    
    [self.operationLock lock];
    
    if (self.size == 0) {
        
        self.head = n;
        self.last = n;
        
    } else {
        
        temp = self.head;
        self.head = n;
        n.next = temp;
        temp.previous = n;
        
    }
    
    self.size += 1;
    
    [self.operationLock unlock];
    
}

- (void)addLast:(id)object {
    
    Node *n = [[Node alloc] init:object n:nil prev:nil];
    
    [self.operationLock lock];
    
    if (self.size == 0) {
        
        self.head = n;
        self.last = n;
        
    } else {
        
        n.previous = self.last;
        self.last.next = n;
        self.last = n;
        
    }
    
    self.size += 1;
    
    [self.operationLock unlock];
    
}

- (Node *)pollFirst {
    
    Node *temp;
    
    [self.operationLock lock];
    
    if (self.size == 0) {
        
        [self.operationLock unlock];
        
        return nil;
        
    } else if (self.size == 1) {
        
        temp = self.head;
        self.head = self.last = nil;
        self.size -= 1;
        
        [self.operationLock unlock];
        
        return temp;
        
    } else {
        
        temp = self.head;
        self.head = self.head.next;
        self.head.previous = nil;
        self.size -= 1;
        
        [self.operationLock unlock];
        
        return temp;
        
    }
    
}

- (Node *)pollLast {
    
    Node *temp;
    Node *temp2;
    
    [self.operationLock lock];
    
    if (self.size == 0) {
        
        [self.operationLock unlock];
        
        return nil;
        
    } else if (self.size == 1) {
      
        temp = self.head;
        self.head = self.last = nil;
        self.size -= 1;
        
        [self.operationLock unlock];
        
        return temp;
        
    } else {
        
        temp = self.last;
        temp2 = temp.previous;
        temp2.next = nil;
        self.last = temp2;
        self.size -= 1;
        
        [self.operationLock unlock];
        
        return temp;
        
    }
    
}

@end