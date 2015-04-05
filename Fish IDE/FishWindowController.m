//
//  FishWindowController.m
//  Fish IDE
//
//  Created by Jussi Enroos on 8.3.2015.
//  Copyright (c) 2015 Jussi Enroos. All rights reserved.
//

#import "FishWindowController.h"
#import "FishViewController.h"

@interface FishWindowController ()

@end

@implementation FishWindowController

- (void)windowDidLoad {
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    
    self.window.titleVisibility = NSWindowTitleHidden;

    FishViewController *vc = (FishViewController*)self.contentViewController;
    [vc registerStopButton:_stopButton];
}

- (IBAction)playButtonSelected:(id)sender
{
    FishViewController *vc = (FishViewController*)self.contentViewController;
    
    [vc playSelected];
}

- (IBAction)stopButtonSelected:(id)sender
{
    FishViewController *vc = (FishViewController*)self.contentViewController;
    
    [vc stopSelected];
}

@end
