//
//  FishWindowController.m
//  Fish IDE
//
//  Created by Jussi Enroos on 8.3.2015.
//  Copyright (c) 2015 Jussi Enroos. All rights reserved.
//

#import "FishWindowController.h"
#import "FishEditorViewController.h"
#import "FishDocumentView.h"

@interface FishWindowController ()

@end

@implementation FishWindowController

- (void)windowDidLoad {
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    
    self.window.titleVisibility = NSWindowTitleHidden;

    /*FishViewController *vc = (FishViewController*)self.contentViewController;
    FishDocumentView *dv = (FishDocumentView*)vc.view;
    
    dv.stopButton = _stopButton;
    dv.statusField = _statusField;*/
}

- (IBAction)playButtonSelected:(id)sender
{
    FishEditorViewController *vc = (FishEditorViewController*)self.contentViewController;
    
    [vc playSelected];
}

- (IBAction)stopButtonSelected:(id)sender
{
    FishEditorViewController *vc = (FishEditorViewController*)self.contentViewController;
    
    [vc stopSelected];
}

@end
