//
//  FishProgram.h
//  Fish IDE
//
//  Created by Jussi Enroos on 9.3.2015.
//  Copyright (c) 2015 Jussi Enroos. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FishProgram : NSObject

@property NSMutableArray *lines;       // NSStrings (ending in newline?)

// Canvas settings
@property int originX;
@property int originY;

@property int executeAreaWidth;
@property int executeAreaHeight;


+ (instancetype) createProgramFromFileContents:(NSString*) fishFileContents;

@end
