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
        [self createDefaultInstructionSetsForFish];
    }
    
    return self;
}

- (void) createDefaultInstructionSetsForFish
{
    // Direction change instructions
    NSMutableDictionary *direction = [NSMutableDictionary dictionary];
    direction[@"^"] = ^(FishInterpreter* i){[i setDirection:fpp(0,-1)];};
    direction[@"v"] = ^(FishInterpreter* i){[i setDirection:fpp(0,1)];};
    direction[@"<"] = ^(FishInterpreter* i){[i setDirection:fpp(-1,0)];};
    direction[@">"] = ^(FishInterpreter* i){[i setDirection:fpp(1,0)];};
    
    [_instructionSets setObject:direction forKey:@"direction"];
    
    // Mirror instructions
    NSMutableDictionary *mirror = [NSMutableDictionary dictionary];
    mirror[@"|"] = ^(FishInterpreter* i){[i setDirection:fpp(-i.direction.x, i.direction.y)];};
    mirror[@"_"] = ^(FishInterpreter* i){[i setDirection:fpp(i.direction.x, -i.direction.y)];};
    mirror[@"/"] = ^(FishInterpreter* i){[i setDirection:fpp(-i.direction.y, -i.direction.x)];};
    mirror[@"\\"] = ^(FishInterpreter* i){[i setDirection:fpp(i.direction.y, i.direction.x)];};
    mirror[@"#"] = ^(FishInterpreter* i){[i setDirection:fpp(-i.direction.x, -i.direction.y)];};
    
    [_instructionSets setObject:mirror forKey:@"mirror"];
    
    // Hex numbers
    NSMutableDictionary *hexNumber = [NSMutableDictionary dictionary];
    NSString *numbers = @"0123456789abcdef";
    
    for (NSUInteger i = 0; i < numbers.length; i++) {
        NSString *c = [numbers substringWithRange:NSMakeRange(i, 1)];
        hexNumber[c] = ^(FishInterpreter* ip){[ip push:[NSNumber numberWithUnsignedInteger:i]];};
    }
    
    [_instructionSets setObject:hexNumber forKey:@"hexNumber"];
    
    // Arithmetic operators
    NSMutableDictionary *arithmetic = [NSMutableDictionary dictionary];
    arithmetic[@"+"] = ^(FishInterpreter* i){
        double a = [[i pop] doubleValue], b = [[i pop] doubleValue];
        [i push:[NSNumber numberWithDouble:b + a]];
    };
    arithmetic[@"-"] = ^(FishInterpreter* i){
        double a = [[i pop] doubleValue], b = [[i pop] doubleValue];
        [i push:[NSNumber numberWithDouble:b - a]];
    };
    arithmetic[@"*"] = ^(FishInterpreter* i){
        double a = [[i pop] doubleValue], b = [[i pop] doubleValue];
        [i push:[NSNumber numberWithDouble:b * a]];
    };
    arithmetic[@","] = ^(FishInterpreter* i){
        double a = [[i pop] doubleValue], b = [[i pop] doubleValue];
        // NOTE: In this case this is a valid comparison
        if (a == 0.0) {
            [i setError:fie_divisionByZero];
            return;
        }
        [i push:[NSNumber numberWithDouble:b / a]];
    };
    arithmetic[@"%"] = ^(FishInterpreter* i){
        double a = [[i pop] doubleValue], b = [[i pop] doubleValue];
        [i push:[NSNumber numberWithDouble:fmod(b, a)]];
    };
    
    [_instructionSets setObject:arithmetic forKey:@"arithmetic"];
}

- (NSDictionary*)instructionSetForName:(NSString *)setName
{
    return nil;
}

- (NSArray *)defaultInstructionSets
{
    return @[_instructionSets[@"direction"],
             _instructionSets[@"mirror"],
             _instructionSets[@"hexNumber"],
             _instructionSets[@"arithmetic"]];
}

@end
