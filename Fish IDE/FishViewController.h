//
//  ViewController.h
//  Fish IDE
//
//  Created by Jussi Enroos on 8.3.2015.
//  Copyright (c) 2015 Jussi Enroos. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "FishScrollView.h"

@interface FishViewController : NSViewController

@property IBOutlet NSTextView *textView;
@property IBOutlet FishScrollView *contentView;

@end

