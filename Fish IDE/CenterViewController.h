//
//  CenterViewController.h
//  Fish IDE
//
//  Created by Jussi Enroos on 6.4.2015.
//  Copyright (c) 2015 Jussi Enroos. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "FishEditorViewController.h"

@interface CenterViewController : NSSplitViewController

@property (weak) FishEditorViewController *editorView;

@end
