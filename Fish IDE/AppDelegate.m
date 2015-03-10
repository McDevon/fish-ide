//
//  AppDelegate.m
//  Fish IDE
//
//  Created by Jussi Enroos on 8.3.2015.
//  Copyright (c) 2015 Jussi Enroos. All rights reserved.
//

#import "AppDelegate.h"

#ifdef DEBUG
#import "DebugTestClass.h"
#endif

@interface AppDelegate ()

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
    
#ifdef DEBUG
    // Simple testing of classes
    DebugTestClass *t = [[DebugTestClass alloc] init];
    [t run];
#endif
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

@end
