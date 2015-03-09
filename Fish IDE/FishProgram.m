//
//  FishProgram.m
//  Fish IDE
//
//  Created by Jussi Enroos on 9.3.2015.
//  Copyright (c) 2015 Jussi Enroos. All rights reserved.
//

#import "FishProgram.h"

@implementation FishProgram

- (instancetype)init
{
    if (self = [super init]) {
        _originX = 0;
        _originY = 0;

        _lines = [[NSMutableArray alloc] init];
    }
    
    return self;
}

+ (instancetype)createProgramFromFileContents:(NSString *)fishFileContents
{
    FishProgram *prog = [[FishProgram alloc] init];
    
    // Go through the file and make each line a string for the program
    const char *str = [fishFileContents cStringUsingEncoding:NSASCIIStringEncoding];
    UInt32 i = 0;
    size_t longest = 0;
    int line = 0;
    
    while (str[i] != '\0') {
        
        if (str[i] == '\n') {
            // Create a line and add to array
            size_t textSize = i - line + 1;
            
            char *text = malloc(textSize);
            strncpy(text, &str[line], textSize - 1);
            text[textSize - 1] = '\0';
            
            NSString *string = [NSString stringWithUTF8String:text];
            [prog.lines addObject:string];
            
            // Log the lines for now
            NSLog(@"%@", string);
            
            free (text);
            
            // Set beginning of next line
            line = i+1;
            
            // Check for longest lines
            if (textSize-1 > longest) {
                longest = textSize-1;
            }
        }
    }
    
    prog.executeAreaWidth = (int)longest;
    prog.executeAreaHeight = (int)[prog.lines count];
    
    return nil;
}

@end
