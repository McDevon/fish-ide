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

// Floating point number comparison ripped from
// http://www.cygnus-software.com/papers/comparingfloats/comparingfloats.htm

BOOL almostEqual(float A, float B, int maxUlps)
{
    // Make sure maxUlps is non-negative and small enough that the
    // default NAN won't compare as equal to anything.
    assert(maxUlps > 0 && maxUlps < 4 * 1024 * 1024);
    int aInt = *(int*)&A;
    // Make aInt lexicographically ordered as a twos-complement int
    if (aInt < 0)
        aInt = 0x80000000 - aInt;
    // Make bInt lexicographically ordered as a twos-complement int
    int bInt = *(int*)&B;
    if (bInt < 0)
        bInt = 0x80000000 - bInt;
    int intDiff = abs(aInt - bInt);
    if (intDiff <= maxUlps)
        return YES;
    return NO;
}

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
        float a = [[i pop] floatValue], b = [[i pop] floatValue];
        [i push:[NSNumber numberWithFloat:b + a]];
    };
    arithmetic[@"-"] = ^(FishInterpreter* i){
        float a = [[i pop] floatValue], b = [[i pop] floatValue];
        [i push:[NSNumber numberWithFloat:b - a]];
    };
    arithmetic[@"*"] = ^(FishInterpreter* i){
        float a = [[i pop] floatValue], b = [[i pop] floatValue];
        [i push:[NSNumber numberWithFloat:b * a]];
    };
    arithmetic[@","] = ^(FishInterpreter* i){
        float a = [[i pop] floatValue], b = [[i pop] floatValue];
        // NOTE: In this case this is a valid comparison
        if (a == 0.0) {
            [i setError:fie_divisionByZero];
            return;
        }
        [i push:[NSNumber numberWithFloat:b / a]];
    };
    arithmetic[@"%"] = ^(FishInterpreter* i){
        float a = [[i pop] floatValue], b = [[i pop] floatValue];
        [i push:[NSNumber numberWithFloat:fmod(b, a)]];
    };
    
    [_instructionSets setObject:arithmetic forKey:@"arithmetic"];
    
    // Comparison operators
    NSMutableDictionary *comparison = [NSMutableDictionary dictionary];
    comparison[@"="] = ^(FishInterpreter* i){
        float a = [[i pop] floatValue], b = [[i pop] floatValue];
        int result = almostEqual(a, b, 4) ? 1 : 0;
        [i push:[NSNumber numberWithInt:result]];
    };
    comparison[@"("] = ^(FishInterpreter* i){
        float a = [[i pop] floatValue], b = [[i pop] floatValue];
        int result = b < a ? 1 : 0;
        [i push:[NSNumber numberWithInt:result]];
    };
    comparison[@")"] = ^(FishInterpreter* i){
        float a = [[i pop] floatValue], b = [[i pop] floatValue];
        int result = b > a ? 1 : 0;
        [i push:[NSNumber numberWithInt:result]];
    };
    
    [_instructionSets setObject:comparison forKey:@"comparison"];
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
             _instructionSets[@"arithmetic"],
             _instructionSets[@"comparison"]];
}

@end
