//
//  ViewController.m
//  Fish IDE
//
//  Created by Jussi Enroos on 8.3.2015.
//  Copyright (c) 2015 Jussi Enroos. All rights reserved.
//

#import "FishViewController.h"
#import "FishDocumentView.h"

@implementation FishViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // Do any additional setup after loading the view.
}

- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}

- (void)playSelected
{
    FishDocumentView *dv = (FishDocumentView*)self.view;
    [dv playSelected];
}

- (void)stopSelected
{
    FishDocumentView *dv = (FishDocumentView*)self.view;
    [dv stopSelected];
}

@end
