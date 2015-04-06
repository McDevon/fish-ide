//
//  FishProgram.h
//  Fish IDE
//
//  Created by Jussi Enroos on 9.3.2015.
//  Copyright (c) 2015 Jussi Enroos. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef struct {
    int x;
    int y;
} FPoint;

typedef struct {
    int width;
    int height;
} FSize;

FPoint fpp(int x, int y);
FSize fsz(int width, int height);

@interface FishProgram : NSObject

@property NSMutableArray *lines;       // NSStrings (ending in newline?)

+ (instancetype) programFromFileContents:(NSString*) fishFileContents;
+ (instancetype) programFromLines:(NSArray*) lines;

@end
