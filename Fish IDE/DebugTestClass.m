//
//  DebugTestClass.m
//  Fish IDE
//
//  Created by Jussi Enroos on 10.3.2015.
//  Copyright (c) 2015 Jussi Enroos. All rights reserved.
//

#import "DebugTestClass.h"
#import "FishProgram.h"
#import "FishInterpreter.h"
#import "FishInstructionSetManager.h"

@implementation DebugTestClass

- (void)run
{
    FishInstructionSetManager * isManager = [[FishInstructionSetManager alloc] init];

    /*NSString *fileContents =
    @"<^;a\\/<^\n"
    @"t>    vrivi\n"
    @">^lm\\/ >\n";*/
    
    NSString *fileContents =
    @"'  !dlroW olleH'>l0)?vov \n"
    @"                ^      < \n"
    @"                     ;   \n"
    @"'0123456789'5[0];\n"
    @" 00v  ;\n"
    @"t;3x2; ^rivi\n"
    @">^l!\\/ >\n";

    
    FishProgram *prog = [FishProgram programFromFileContents:fileContents];
    
    NSLog(@"%@", prog);
    
    FishInterpreter *interperter = [[FishInterpreter alloc] initWithISManager:isManager];
    
    [interperter initializeProgram:prog];
    
    FishInterpreterError error = fie_none;
    while (error == fie_none) {
        error = [interperter executeStep];
    }
    NSLog(@"done %d", error);
}

@end
