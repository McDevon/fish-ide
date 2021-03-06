//
//  FishInterpreter.m
//  Fish IDE
//
//  Created by Jussi Enroos on 9.3.2015.
//  Copyright (c) 2015 Jussi Enroos. All rights reserved.
//

#import "FishInterpreter.h"

#import "FishInstructionSetManager.h"
#import "FishContext.h"

#ifdef DEBUG

#define __FISHLOG(s, ...) \
NSLog(@"%@",[NSString stringWithFormat:(s), ##__VA_ARGS__])

// Debug logging for interpreter
#define ENABLE_FISHLOG
#undef ENABLE_FISHLOG

#endif

// Own logging macro
#ifdef ENABLE_FISHLOG
#   define FISHLOG(...) __FISHLOG(__VA_ARGS__)
#else
#   define FISHLOG(...) do {} while (0)
#endif


@implementation FishInterpreter
{
    // Line lengths
    NSMutableArray *_lineLengths;
        
    BOOL _skip;
    
    // List of enabled instruction sets
    NSArray *_enabledInstructionSets;
    
    FishInterpreterError _error;
}

+ (NSString*) errorString:(FishInterpreterError) error
{
    switch (error) {
        case fie_none:
            return @"No error";
        case fie_notInitialized:
            return @"Interpreter not initialized";
        case fie_finished:
            return @"Program finished";
        case fie_invalidInstruction:
            return @"Invalid instruction";
        case fie_popEmptyStack:
            return @"Tried to pop empty stack";
        case fie_popFromEmptySlot:
            return @"Tried to pop from empty stack location";
        case fie_divisionByZero:
            return @"Division by zero";
        case fie_negativeIPPosition:
            return @"Negative IP position";
        case fie_notEnoughValuesInStack:
            return @"Not enough values in stack";
    }
    
    return @"Unrecognized error";
}

- (instancetype)initWithISManager:(FishInstructionSetManager*) isManager
{
    if (self = [super init]) {
        _codebox = [[NSMutableDictionary alloc] init];
        _lineLengths = [[NSMutableArray alloc] init];
        _currentContext = [[FishContext alloc] init];
        _contextStack = [[NSMutableArray alloc] init];
        
        [_contextStack addObject:_currentContext];
        
        _ip = fpp(-1, 0);
        _direction = fpp(1, 0); // Initially move right
        
        _skip = NO;
        _stringMode = nil;
        
        _error = fie_none;
        
        _enabledInstructionSets = [isManager defaultInstructionSets];
    }
    
    return self;
}

- (BOOL)initializeProgram:(FishProgram *)program
{
    [_lineLengths removeAllObjects];
    [_codebox removeAllObjects];
    [_contextStack removeAllObjects];
    
    _currentContext = [[FishContext alloc] init];
    [_contextStack addObject:_currentContext];
    
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
    
    // Initial values
    _ip = fpp(-1, 0);
    _direction = fpp(1, 0); // Initially move right
    
    _skip = NO;
    _stringMode = nil;
    
    _error = fie_none;
    
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
    
    // Notify delegate
    [_delegate ipMovedTo:_ip];
    
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
    
    if (_stringMode != nil && !!![instruction isEqualToString:_stringMode]) {
        // Push character number to stack
        char c;
        if (instruction == nil) {
            c = ' ';
        }
        else {
            c = [instruction characterAtIndex:0];
        }
        NSNumber *n = [NSNumber numberWithChar:c];
        FISHLOG(@"Push char %c", c);
        [self push:n];
        return fie_none;
    }
    else if (instruction != nil && [instruction isEqualToString:_stringMode]) {
        FISHLOG(@"End string mode");
        _stringMode = nil;
        return fie_none;
    }
    
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
    
    for (NSNumber *number in _currentContext.stack) {
        [stack appendFormat:@"%@ ", number];
    }
    
    return stack;
}

#pragma mark - Interpreter commands

- (NSNumber*) pop
{
    if (_currentContext.stack.count == 0) {
        // Nothing to pop!
        _error = fie_popEmptyStack;
        return nil;
    }
    
    NSNumber *top = [_currentContext.stack lastObject];
    [_currentContext.stack removeLastObject];
    
    FISHLOG(@"Pop. Stack: %@", [self stackString]);
    
    return top;
}

- (NSNumber *) popIndex:(NSUInteger)index
{
    if (_currentContext.stack.count <= index) {
        // Nothing to pop!
        _error = fie_popFromEmptySlot;
        return nil;
    }
    
    NSNumber *top = [_currentContext.stack objectAtIndex:index];
    [_currentContext.stack removeObjectAtIndex:index];
    
    FISHLOG(@"Pop from %lu. Stack: %@", index, [self stackString]);
    
    return top;
}

- (void) push:(NSNumber*) number
{
    [_currentContext.stack addObject:number];
    
    FISHLOG(@"Push. Stack: %@", [self stackString]);
}

- (void) push:(NSNumber*) number index:(NSUInteger) index
{
    [_currentContext.stack insertObject:number atIndex:index];
    
    FISHLOG(@"Push. Stack: %@", [self stackString]);
}

- (void) reverseStack
{
    NSEnumerator *e = [_currentContext.stack reverseObjectEnumerator];
    
    // As allObjects is not defined to return the objects in order (although it does), the reversing is done with a loop
    NSMutableArray *array = [NSMutableArray array];
    NSNumber *n;
    while ((n = [e nextObject]) != nil) {
        [array addObject:n];
    }
    _currentContext.stack = array;
}

- (NSUInteger)stackSize
{
    return [_currentContext.stack count];
}

- (NSNumber *)getRegister
{
    return _currentContext.contextRegister;
}

- (void)setRegister:(NSNumber*) value
{
    _currentContext.contextRegister = value;
}

- (void) pushContext:(FishContext*) context
{
    [_contextStack addObject:context];
    _currentContext = context;
    FISHLOG(@"Push context, context stack size %lu", [_contextStack count]);
}

- (FishContext *) popContext
{
    if ([_contextStack count] > 0) {
        FishContext *c = [_contextStack lastObject];
        [_contextStack removeLastObject];
        if ([_contextStack count] > 0) {
            FISHLOG(@"Pop context, context stack size: %lu", [_contextStack count]);
            _currentContext = [_contextStack lastObject];
        } else {
            FISHLOG(@"Pop context, context stack clear");
            _currentContext = nil;
        }
        return c;
    }
    FISHLOG(@"Pop context, nothing to pop");
    return nil;
}

- (void) output:(NSString *)string
{
    // Just print for now
    // TODO: proper output to console
    printf("%s", [string cStringUsingEncoding:NSASCIIStringEncoding]);
    
    [_delegate output:string];
}

- (void) input
{
    // Just add something for now
    // TODO: proper input
    //[self push:[NSNumber numberWithChar:'M']];
    
    [_delegate requestInput];
}

- (void) provideInput:(NSNumber *)input
{
    [self push:input];
}

- (void) skip
{
    _skip = YES;
}

- (void) setError:(FishInterpreterError)error
{
    _error = error;
}

@end
