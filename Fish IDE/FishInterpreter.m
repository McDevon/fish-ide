//
//  FishInterpreter.m
//  Fish IDE
//
//  Created by Jussi Enroos on 9.3.2015.
//  Copyright (c) 2015 Jussi Enroos. All rights reserved.
//

#import "FishInterpreter.h"

#import "FishInstructionSetManager.h"

#ifdef DEBUG

#define __FISHLOG(s, ...) \
NSLog(@"%@",[NSString stringWithFormat:(s), ##__VA_ARGS__])

// Debug logging for interpreter
#define ENABLE_FISHLOG
//#undef ENABLE_FISHLOG

#endif

// Own logging macro
#ifdef ENABLE_FISHLOG
#   define FISHLOG(...) __FISHLOG(__VA_ARGS__)
#else
#   define FISHLOG(...) do {} while (0)
#endif


@implementation FishInterpreter
{
    // Program
    NSMutableDictionary *_codebox;
    
    // Line lengths
    NSMutableArray *_lineLengths;
        
    BOOL _skip;
    
    // List of enabled instruction sets
    NSArray *_enabledInstructionSets;
    
    // Stacks
    NSMutableArray *_currentStack;
    NSMutableArray *_stackStack;
    
    FishInterpreterError _error;
}

- (instancetype)initWithISManager:(FishInstructionSetManager*) isManager
{
    if (self = [super init]) {
        _codebox = [[NSMutableDictionary alloc] init];
        _lineLengths = [[NSMutableArray alloc] init];
        _currentStack = [[NSMutableArray alloc] init];
        _stackStack = [[NSMutableArray alloc] init];
        
        [_stackStack addObject:_currentStack];
        
        _ip = fpp(-1, 0);
        _direction = fpp(1, 0); // Initially move right
        
        _skip = NO;
        
        _error = fie_none;
        
        _enabledInstructionSets = [isManager defaultInstructionSets];
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
    
    // Check boundaries and wrap around if beyond edge
    if (_ip.y < 0) {
        _ip.y = lines - 1;
    } else if (_ip.y >= lines) {
        _ip.y = 0;
    }
    else {
        NSNumber *lLength = [_lineLengths objectAtIndex:_ip.y];
        int lineLength = [lLength intValue];
        
        if (_ip.x < 0) {
            _ip.x = lineLength - 1;
        } else if (_ip.x >= lineLength) {
            _ip.x = 0;
        }
    }
    
    FISHLOG(@"IP at %d, %d Dir: %d, %d", _ip.x, _ip.y, _direction.x, _direction.y);

    if (_skip) {
        // Next instruction is skipped, don't interpret it
        _skip = NO;
        
        FISHLOG(@"Skip");
        return fie_none;
    }
    
    // TODO: interpret instruction
    NSString *key = [NSString stringWithFormat:@"%d,%d", _ip.x, _ip.y];
    NSString *instruction = [_codebox objectForKey:key];
    
    if (instruction == nil || [instruction isEqualToString:@" "]) {
        // No instruction here or whitespace, interpret as whitespace
        return fie_none;
    }
    
    // Go through basic instructions and extensions in use
    for (NSDictionary *instructionSet in _enabledInstructionSets) {
        FishInterpreterError (^instructionHandler)(FishInterpreter*) = [instructionSet objectForKey:instruction];
        
        // Instruction found, interpret it
        if (instructionHandler != nil) {
            FISHLOG(@"Interpreting instruction %@", instruction);
            instructionHandler(self);
            return _error;
        }
    }
    
    // Instruction not found, return error
    return fie_invalidInstruction;
}

#pragma mark - Debug methods

- (NSString*) stackString
{
    // Current stack as string
    NSMutableString *stack = [NSMutableString string];
    
    for (NSNumber *number in _currentStack) {
        [stack appendFormat:@"%@ ", number];
    }
    
    return stack;
}

#pragma mark - Interpreter commands

- (NSNumber*) pop
{
    if (_currentStack.count == 0) {
        // Nothing to pop!
        _error = fie_popEmptyStack;
        return nil;
    }
    
    NSNumber *top = [_currentStack lastObject];
    [_currentStack removeLastObject];
    
    FISHLOG(@"Pop. Stack: %@", [self stackString]);
    
    return top;
}

- (void) push:(NSNumber*) number
{
    [_currentStack addObject:number];
    
    FISHLOG(@"Push. Stack: %@", [self stackString]);
}

- (void) push:(NSNumber*) number index:(NSUInteger) index
{
    [_currentStack insertObject:number atIndex:index];
    
    FISHLOG(@"Push. Stack: %@", [self stackString]);
}

- (void)setError:(FishInterpreterError)error
{
    _error = error;
}

@end
