//
//  FishInterpreter.h
//  Fish IDE
//
//  Created by Jussi Enroos on 9.3.2015.
//  Copyright (c) 2015 Jussi Enroos. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FishProgram.h"

typedef enum {
    fie_none,
    fie_notInitialized,
    fie_finished,
} FishInterpreterError;

@interface FishInterpreter : NSObject

- (BOOL) initializeProgram:(FishProgram*) program;

- (FishInterpreterError) executeStep;

@end
