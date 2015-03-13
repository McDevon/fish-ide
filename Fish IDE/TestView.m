//
//  TestView.m
//  Fish IDE
//
//  Created by Jussi Enroos on 13.3.2015.
//  Copyright (c) 2015 Jussi Enroos. All rights reserved.
//

#import "TestView.h"

@implementation TestView

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Draw a red tile with a blue border.
    [[NSColor blueColor] set];
    NSRectFill(self.bounds);
    
    [[NSColor redColor] setFill];
    NSRectFill(NSInsetRect(self.bounds, 2,2));
}

@end
