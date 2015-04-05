//
//  FishDocumentView.h
//  Fish IDE
//
//  Created by Jussi Enroos on 13.3.2015.
//  Copyright (c) 2015 Jussi Enroos. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "FishInterpreter.h"

@interface FishDocumentView : NSView <FishInterpreterDelegate>

- (void) playSelected;
- (void) stopSelected;

@end
