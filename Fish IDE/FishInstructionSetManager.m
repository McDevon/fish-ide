//
//  FishInstructionSetManager.m
//  Fish IDE
//
//  Created by Jussi Enroos on 10.3.2015.
//  Copyright (c) 2015 Jussi Enroos. All rights reserved.
//

#import "FishInstructionSetManager.h"
#import "FishInterpreter.h"
#import "FishProgram.h"

@implementation FishInstructionSetManager
{
    NSMutableDictionary *_instructionSets;
}

- (instancetype)init
{
    if (self = [super init]) {
        _instructionSets = [[NSMutableDictionary alloc] init];
        [self createDefaultInstructionSets];
    }
    
    return self;
}

- (void) createDefaultInstructionSets
{
    // Direction change instructions
    NSMutableDictionary *direction = [NSMutableDictionary dictionary];
    direction[@"^"] = ^FishInterpreterError(FishInterpreter* i){[i setDirection:fpp(0,-1)]; return fie_none;};
    direction[@"v"] = ^FishInterpreterError(FishInterpreter* i){[i setDirection:fpp(0,1)]; return fie_none;};
    direction[@"<"] = ^FishInterpreterError(FishInterpreter* i){[i setDirection:fpp(-1,0)]; return fie_none;};
    direction[@">"] = ^FishInterpreterError(FishInterpreter* i){[i setDirection:fpp(1,0)]; return fie_none;};
    
    [_instructionSets setObject:direction forKey:@"direction"];
}

- (NSDictionary*)instructionSetForName:(NSString *)setName
{
    return nil;
}

- (NSArray *)defaultInstructionSets
{
    return @[_instructionSets[@"direction"]];
}

@end
