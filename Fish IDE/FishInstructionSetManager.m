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
#import "FishContext.h"

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
        [i push:[NSNumber numberWithInt:almostEqual(a, b, 4) ? 1 : 0]];
    };
    comparison[@"("] = ^(FishInterpreter* i){
        float a = [[i pop] floatValue], b = [[i pop] floatValue];
        [i push:[NSNumber numberWithInt:b < a ? 1 : 0]];
    };
    comparison[@")"] = ^(FishInterpreter* i){
        float a = [[i pop] floatValue], b = [[i pop] floatValue];
        [i push:[NSNumber numberWithInt:b > a ? 1 : 0]];
    };
    
    [_instructionSets setObject:comparison forKey:@"comparison"];
    
    // String mode
    NSMutableDictionary *stringMode = [NSMutableDictionary dictionary];
    stringMode[@"\""] = ^(FishInterpreter* i){i.stringMode = @"\"";};
    stringMode[@"'"]  = ^(FishInterpreter* i){i.stringMode = @"'";};
    
    [_instructionSets setObject:stringMode forKey:@"stringMode"];
    
    // Movement manipulation
    NSMutableDictionary *movement = [NSMutableDictionary dictionary];
    // Random direction
    movement[@"x"] = ^(FishInterpreter* i){
        int r = arc4random_uniform(4);
        switch (r) {
            case 0:
                i.direction = fpp(0,-1);
                break;
            case 1:
                i.direction = fpp(0,1);
                break;
            case 2:
                i.direction = fpp(-1,0);
                break;
            case 3:
                i.direction = fpp(1,0);
                break;
                
            default:
                break;
        }
    };
    // Portal
    movement[@"."] = ^(FishInterpreter* i){
        int y = [i.pop intValue], x = [i.pop intValue];
        if (x < 0 || y < 0) {
            [i setError:fie_negativeIPPosition];
            return;
        }
        i.ip = fpp(x, y);
    };
    // Jump
    movement[@"!"] = ^(FishInterpreter* i){[i skip];};
    // Conditional jump
    movement[@"?"] = ^(FishInterpreter* i){
        float a = [[i pop] floatValue];
        if (!almostEqual(a, 0.f, 3)) {
            [i skip];
        }
    };
    
    [_instructionSets setObject:movement forKey:@"movement"];
    
    // Stack manipulation
    NSMutableDictionary *stack = [NSMutableDictionary dictionary];
    // Duplicate
    stack[@":"] = ^(FishInterpreter* i){
        NSNumber *n = [i pop];
        [i push:n];
        [i push:[n copy]];
    };
    // Remove top value
    stack[@"~"] = ^(FishInterpreter* i){[i pop];};
    // Swap top two values
    stack[@"$"] = ^(FishInterpreter* i){
        NSNumber *a = [i pop], *b = [i pop];
        [i push:a];
        [i push:b];
    };
    // Swap top three values
    stack[@"@"] = ^(FishInterpreter* i){
        NSNumber *a = [i pop], *b = [i pop], *c = [i pop];
        [i push:a];
        [i push:c];
        [i push:b];
    };
    // Shift stack left
    stack[@"{"] = ^(FishInterpreter* i){[i push:[i popIndex:0]];};
    // Shift stack right
    stack[@"}"] = ^(FishInterpreter* i){[i push:[i pop] index:0];};
    // Reverse stack
    stack[@"r"] = ^(FishInterpreter* i){[i reverseStack];};
    // Push stack length
    stack[@"l"] = ^(FishInterpreter* i){[i push:[NSNumber numberWithUnsignedInteger:[i stackSize]]];};
    // Register call
    stack[@"&"] = ^(FishInterpreter* i){
        NSNumber *r = [i getRegister];
        if (r == nil) {
            r = [i pop];
            [i setRegister:r];
        } else {
            [i push:r];
            [i setRegister:nil];
        }
    };
    
    [_instructionSets setObject:stack forKey:@"stack"];

    // Subprograms with separate context
    NSMutableDictionary *sub = [NSMutableDictionary dictionary];
    
    sub[@"["] = ^(FishInterpreter* i){
        // Pop value and move that many values to new stack
        int count = [[i pop] intValue];
        
        NSUInteger c = [i stackSize];
        if (count < 0) {
            count = (int)c + count;
        }
        
        if (count > (int)c) {
            [i setError:fie_notEnoughValuesInStack];
            return;
        }
        c -= count;
        
        // Create new context
        FishContext *context = [[FishContext alloc] init];
        
        // Copy values from old stack to new
        for (NSUInteger k = 0; k < count; k++) {
            [context.stack addObject:[i popIndex:c]];
        }
        
        // Take new context in use (old register is not touched)
        [i pushContext:context];
    };
    sub[@"]"] = ^(FishInterpreter *i){
        FishContext *old = [i popContext];
        if ([i.contextStack count] == 0) {
            // Create new empty context
            [i pushContext:[[FishContext alloc] init]];
        } else {
            // Add old stack on top of new
            NSUInteger count = [old.stack count];
            for (NSUInteger k = 0; k < count; k++) {
                [i push:[old.stack objectAtIndex:k]];
            }
        }
    };
    
    [_instructionSets setObject:sub forKey:@"sub"];
    
    // I/O
    NSMutableDictionary *io = [NSMutableDictionary dictionary];
    
    sub[@"o"] = ^(FishInterpreter* i){
        // Print the top value as a character
        NSNumber *n = [i pop];
        if (n == nil) {return;}
        [i output:[NSString stringWithFormat:@"%c", [n charValue]]];
    };

    sub[@"n"] = ^(FishInterpreter* i){
        // Print the top value as a number
        NSNumber *n = [i pop];
        if (n == nil) {return;}
        float v = [n floatValue];
        float r = fmodf(v, 1.f);
        if (almostEqual(r, 0.f, 3)) {
            [i output:[NSString stringWithFormat:@"%.0f", v]];
        } else {
            [i output:[NSString stringWithFormat:@"%f", v]];
        }
    };
    
    sub[@"i"] = ^(FishInterpreter* i){
        // Input a single char from stdin or equivalent
        [i input];
    };

    [_instructionSets setObject:io forKey:@"io"];
    
    // Program flow
    NSMutableDictionary *flow = [NSMutableDictionary dictionary];
    flow[@";"] = ^(FishInterpreter* i){[i setError:fie_finished];};
    
    [_instructionSets setObject:flow forKey:@"flow"];

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
             _instructionSets[@"comparison"],
             _instructionSets[@"stringMode"],
             _instructionSets[@"movement"],
             _instructionSets[@"stack"],
             _instructionSets[@"sub"],
             _instructionSets[@"io"],
             _instructionSets[@"flow"]];
}

@end
