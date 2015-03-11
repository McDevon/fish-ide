//
//  FishContext.h
//  Fish IDE
//
//  Created by Jussi Enroos on 10.3.2015.
//  Copyright (c) 2015 Jussi Enroos. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FishContext : NSObject

@property NSMutableArray *stack;
@property NSNumber *contextRegister;

@end
