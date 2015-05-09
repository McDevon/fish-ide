//
//  FishWindowController.h
//  Fish IDE
//
//  Created by Jussi Enroos on 8.3.2015.
//  Copyright (c) 2015 Jussi Enroos. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface FishWindowController : NSWindowController <NSWindowDelegate>

@property (weak) IBOutlet NSButton *playButton;
@property (weak) IBOutlet NSButton *stopButton;

@property (weak) IBOutlet NSTextField *statusField;

- (IBAction) playButtonSelected:(id) sender;
- (IBAction) stopButtonSelected:(id) sender;

@end
