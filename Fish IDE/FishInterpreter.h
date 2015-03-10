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
} FishInterpreterError;

@interface FishInterpreter : NSObject

- (instancetype)initWithISManager:(FishInstructionSetManager*) isManager;

- (BOOL) initializeProgram:(FishProgram*) program;

- (FishInterpreterError) executeStep;

// Instruction commands
- (void) setDirection:(FPoint) direction;

@end
