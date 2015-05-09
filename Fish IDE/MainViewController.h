//
//  MainViewController.h
//  Fish IDE
//
//  Created by Jussi Enroos on 6.4.2015.
//  Copyright (c) 2015 Jussi Enroos. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "CenterViewController.h"

@interface MainViewController : NSSplitViewController

@property (weak) CenterViewController *center;

@end
