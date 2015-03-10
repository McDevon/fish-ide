//
//  FishInterpreter.h
//  Fish IDE
//
//  Created by Jussi Enroos on 9.3.2015.
//  Copyright (c) 2015 Jussi Enroos. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FishProgram.h"

@class FishInstructionSetManager;

typedef enum {
    fie_none,
    fie_notInitialized,
    fie_finished,
    fie_invalidInstruction,
    fie_popEmptyStack,
    fie_divisionByZero,
} FishInterpreterError;

@interface FishInterpreter : NSObject

// Interpreter state
@property FPoint ip; // Instruction pointer
@property FPoint direction; // IP direction



- (instancetype)initWithISManager:(FishInstructionSetManager*) isManager;

- (BOOL) initializeProgram:(FishProgram*) program;

- (FishInterpreterError) executeStep;

// Instruction commands
- (void) setDirection:(FPoint) direction;
- (void) push:(NSNumber*) number;
- (void) push:(NSNumber*) number index:(NSUInteger) index;
- (NSNumber*) pop;

- (void) setError:(FishInterpreterError) error;

@end
