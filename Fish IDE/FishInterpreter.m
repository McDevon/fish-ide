//
//  FishInterpreter.m
//  Fish IDE
//
//  Created by Jussi Enroos on 9.3.2015.
//  Copyright (c) 2015 Jussi Enroos. All rights reserved.
//

#import "FishInterpreter.h"

@implementation FishInterpreter
{
    // Program
    NSMutableDictionary *_codebox;
    
    // Line lengths
    NSMutableArray *_lineLengths;
    
    // Instruction pointer
    FPoint _ip;
    
    // Moving direction
    FPoint _direction;
}

- (instancetype)init
{
    if (self = [super init]) {
        _codebox = [[NSMutableDictionary alloc] init];
        _lineLengths = [[NSMutableArray alloc] init];
        
        _ip = fpp(-1, 0);
        _direction = fpp(1, 0); // Initially move right
    }
    
    return self;
}

- (BOOL)initializeProgram:(FishProgram *)program
{
    // Go through lines and add chars to codebox
    int j = 0;
    for (NSString *line in [program lines]) {
        for (NSUInteger i = 0; i < line.length; i++) {
            NSString *c = [line substringWithRange:NSMakeRange(i, 1)];
            
            // Create key
            NSString *key = [NSString stringWithFormat:@"%lu,%d", i, j];
            
            NSLog(@"Key: %@ char: %@", key, c);
            
            [_codebox setObject:c forKey:key];
        }
        [_lineLengths addObject:[NSNumber numberWithUnsignedInteger:line.length]];
        ++j;
    }
    
    return YES;
}

- (FishInterpreterError)executeStep
{
    // Move ip
    _ip.x += _direction.x;
    _ip.y += _direction.y;
    
    int lines = (int)[_lineLengths count];
    NSNumber *lLength = [_lineLengths objectAtIndex:_ip.y];
    int lineLength = [lLength intValue];
    
    // Check boundaries and wrap around if needed
    if (_ip.y < 0) {
        _ip.y = lines - 1;
    } else if (_ip.y >= lines) {
        _ip.y = 0;
    } else if (_ip.x < 0) {
        _ip.x = lineLength - 1;
    } else if (_ip.x >= lineLength) {
        _ip.x = 0;
    }
    
    // TODO: interpret instruction
    NSString *key = [NSString stringWithFormat:@"%d,%d", _ip.x, _ip.y];
    NSString *instruction = [_codebox objectForKey:key];
    
    if (instruction == nil || [instruction isEqualToString:@" "]) {
        // No instruction here or whitespace, interpret as whitespace
        return fie_none;
    }
    
    // Go through basic instructions and extensions in use
    
    
    return fie_none;
}


@end
