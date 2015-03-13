//
//  FishScrollView.h
//  Fish IDE
//
//  Created by Jussi Enroos on 13.3.2015.
//  Copyright (c) 2015 Jussi Enroos. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface FishScrollView : NSScrollView

- (void)updateTiles;
@property (nonatomic, readonly, retain) NSMutableArray* reusableViews;

@end
