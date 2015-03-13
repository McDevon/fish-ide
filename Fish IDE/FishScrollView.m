//
//  FishScrollView.m
//  Fish IDE
//
//  Created by Jussi Enroos on 13.3.2015.
//  Copyright (c) 2015 Jussi Enroos. All rights reserved.
//

#import "FishScrollView.h"
#import "TestView.h"

@implementation FishScrollView
{
    NSMutableArray *_reusableViews;
}

- (NSMutableArray*)reusableViews
{
    if (nil == _reusableViews)
    {
        _reusableViews = [[NSMutableArray alloc] init];
    }
    return _reusableViews;
}

- (void)setReusableViews:(NSMutableArray *)reusableViews
{
    _reusableViews = reusableViews;
}

- (void)reflectScrolledClipView:(NSClipView *)cView
{
    [super reflectScrolledClipView: cView];
    [self updateTiles];
}

- (void)updateTiles
{
    // The size of a tile...
    static const NSSize gGranuleSize = {20.0, 20.0};
    
    NSRect documentVisibleRect = self.documentVisibleRect;
    
    // Determine the needed tiles for coverage
    const CGFloat xMin = floor(NSMinX(documentVisibleRect) / gGranuleSize.width) * gGranuleSize.width;
    const CGFloat xMax = xMin + (ceil((NSMaxX(documentVisibleRect) - xMin) / gGranuleSize.width) * gGranuleSize.width);
    const CGFloat yMin = floor(NSMinY(documentVisibleRect) / gGranuleSize.height) * gGranuleSize.height;
    const CGFloat yMax = ceil((NSMaxY(documentVisibleRect) - yMin) / gGranuleSize.height) * gGranuleSize.height;
    
    // Figure out the tile frames we would need to get full coverage
    NSMutableSet* neededTileFrames = [NSMutableSet set];
    for (CGFloat x = xMin; x < xMax; x += gGranuleSize.width)
    {
        for (CGFloat y = yMin; y < yMax; y += gGranuleSize.height)
        {
            NSRect rect = NSMakeRect(x, y, gGranuleSize.width, gGranuleSize.height);
            [neededTileFrames addObject: [NSValue valueWithRect: rect]];
        }
    }
    
    NSLog(@"xy: %.2f, %.2f -> %.2f, %.2f frames: %lu", xMin, yMin, xMax, yMax, [neededTileFrames count]);
    
    // See if we already have subviews that cover these needed frames.
    for (NSView* subview in [[self.documentView subviews] copy])
    {
        NSValue* frameRectVal = [NSValue valueWithRect: subview.frame];
        
        // If we don't need this one any more...
        if (![neededTileFrames containsObject: frameRectVal])
        {
            // Then recycle it...
            [_reusableViews addObject: subview];
            [subview removeFromSuperview];
        }
        else
        {
            // Take this frame rect off the To-do list.
            [neededTileFrames removeObject: frameRectVal];
        }
    }
    
    // Add needed tiles from the to-do list
    for (NSValue* neededFrame in neededTileFrames)
    {
        NSView* view = [_reusableViews lastObject];
        [_reusableViews removeLastObject];
        
        if (nil == view)
        {
            // Create one if we didnt find a reusable one.
            view = [[TestView alloc] initWithFrame: NSZeroRect];
            //NSLog(@"Created a view.");
        }
        else
        {
            NSLog(@"Reused a view.");
        }
        
        // Place it and install it.
        view.frame = [neededFrame rectValue];
        [view setNeedsDisplay: YES];
        [self.documentView addSubview: view];
    }
}


- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}

@end
