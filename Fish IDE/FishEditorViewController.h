//
//  ViewController.h
//  Fish IDE
//
//  Created by Jussi Enroos on 8.3.2015.
//  Copyright (c) 2015 Jussi Enroos. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface FishEditorViewController : NSViewController

//@property IBOutlet NSTextView *textView;
//@property IBOutlet FishScrollView *contentView;

- (void) playSelected;
- (void) stopSelected;

@property (weak) IBOutlet NSLayoutConstraint *minimumWidth;
@property (weak) IBOutlet NSLayoutConstraint *minimumHeight;

@end

