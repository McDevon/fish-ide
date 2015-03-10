//
//  FishProgram.m
//  Fish IDE
//
//  Created by Jussi Enroos on 9.3.2015.
//  Copyright (c) 2015 Jussi Enroos. All rights reserved.
//

#import "FishProgram.h"

FPoint fpp(int x, int y)
{
    FPoint p; p.x = x; p.y = y; return p;
}

FSize fsz(int width, int height)
{
    FSize s; s.width = width; s.height = height; return s;
}


@implementation FishProgram

- (instancetype)init
{
    if (self = [super init]) {
        _lines = [[NSMutableArray alloc] init];
    }
    
    return self;
}

+ (instancetype)programFromFileContents:(NSString *)fishFileContents
{
    FishProgram *prog = [[FishProgram alloc] init];
    
    // Go through the file and make each line a string for the program
    const char *str = [fishFileContents cStringUsingEncoding:NSASCIIStringEncoding];
    UInt32 i = 0;
    size_t longest = 0;
    int line = 0;
    BOOL done = NO;
    
    while (!done) {
        
        if (str[i] == '\0') {
            if (i > 0 && str[i-1] == '\n') {
                break;
            }
            
            done = YES;
        }
        
        if (str[i] == '\n' || done) {
            // Create a line and add to array
            size_t textSize = i - line + 1;
            
            char *text = malloc(textSize);
            strncpy(text, &str[line], textSize - 1);
            text[textSize - 1] = '\0';
            
            NSString *string = [NSString stringWithUTF8String:text];
            [prog.lines addObject:string];
            
            // Log the lines for now
            //NSLog(@"%@", string);
            
            free (text);
            
            // Set beginning of next line
            line = i+1;
            
            // Check for longest lines
            if (textSize-1 > longest) {
                longest = textSize-1;
            }
        }
        
        i++;
    }
    
    
    return prog;
}

- (NSString *)description
{
    NSMutableString *desc = [NSMutableString stringWithString:@"Rows:\n"];
    
    for (NSString *line in _lines) {
        [desc appendString:[NSString stringWithFormat:@"%@\n", line]];
    }
    
    [desc appendString:[NSString stringWithFormat:@"Row count: %lu", [_lines count]]];
    
    return desc;
}

@end
