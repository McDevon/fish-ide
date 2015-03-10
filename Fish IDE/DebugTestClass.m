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

@implementation DebugTestClass

- (void)run
{
    NSString *fileContents =
    @"eka rivi\n"
    @"toinen rivi\n"
    @"kolmas\n";
    
    FishProgram *prog = [FishProgram programFromFileContents:fileContents];
    
    NSLog(@"%@", prog);
    
    FishInterpreter *interperter = [[FishInterpreter alloc] init];
    
    [interperter initializeProgram:prog];
}

@end
