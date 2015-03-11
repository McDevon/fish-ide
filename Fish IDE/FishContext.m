//
//  FishContext.m
//  Fish IDE
//
//  Created by Jussi Enroos on 10.3.2015.
//  Copyright (c) 2015 Jussi Enroos. All rights reserved.
//

#import "FishContext.h"

@implementation FishContext

- (instancetype)init
{
    if (self = [super init]) {
        _stack = [[NSMutableArray alloc] init];
        _contextRegister = nil;
    }
    return self;
}

@end
