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
@class FishContext;

typedef enum {
    fie_none,
    fie_notInitialized,
    fie_finished,
    fie_invalidInstruction,
    fie_popEmptyStack,
    fie_popFromEmptySlot,
    fie_divisionByZero,
    fie_negativeIPPosition,
    fie_notEnoughValuesInStack,
} FishInterpreterError;

@interface FishInterpreter : NSObject

// Interpreter state
@property FPoint ip; // Instruction pointer
@property FPoint direction; // IP direction

@property NSString *stringMode;

// Stacks
@property FishContext *currentContext;
@property NSMutableArray *contextStack;

// Program
@property NSMutableDictionary *codebox;

- (instancetype)initWithISManager:(FishInstructionSetManager*) isManager;

- (BOOL) initializeProgram:(FishProgram*) program;

- (FishInterpreterError) executeStep;

// Instruction commands
- (void) setDirection:(FPoint) direction;
- (void) skip;
- (void) push:(NSNumber*) number;
- (void) push:(NSNumber*) number index:(NSUInteger) index;
- (NSNumber*) pop;
- (NSNumber*) popIndex:(NSUInteger) index;
- (void) reverseStack;
- (NSUInteger) stackSize;
- (NSNumber*) getRegister;
- (void) setRegister:(NSNumber*) value;

- (void) pushContext:(FishContext*) context;
- (FishContext *) popContext;

- (void) output:(NSString*) string;

- (void) setError:(FishInterpreterError) error;

@end
