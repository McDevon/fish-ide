//
//  ViewController.m
//  Fish IDE
//
//  Created by Jussi Enroos on 8.3.2015.
//  Copyright (c) 2015 Jussi Enroos. All rights reserved.
//

#import "FishEditorViewController.h"
#import "FishDocumentView.h"

@implementation FishEditorViewController

+ (void)addEdgeConstraint:(NSLayoutAttribute)edge superview:(NSView *)superview subview:(NSView *)subview {
    [superview addConstraint:[NSLayoutConstraint constraintWithItem:subview
                                                          attribute:edge
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:superview
                                                          attribute:edge
                                                         multiplier:1
                                                           constant:0]];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    // Do any additional setup after loading the view.
    
    //NSView *contentView = [_window contentView];
    FishDocumentView *customView = (FishDocumentView*)self.view;
    
    /*[customView setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    NSDictionary *views = NSDictionaryOfVariableBindings(customView);
    
    [customView addConstraints:
     [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[customView]|"
                                             options:0
                                             metrics:nil
                                               views:views]];
    
    [customView addConstraints:
     [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[customView]|"
                                             options:0
                                             metrics:nil
                                               views:views]];*/

    [customView setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    //[contentView addSubview:customView];
    
    /*[[self class] addEdgeConstraint:NSLayoutAttributeLeft superview:contentView subview:customView];
    [[self class] addEdgeConstraint:NSLayoutAttributeRight superview:contentView subview:customView];
    [[self class] addEdgeConstraint:NSLayoutAttributeTop superview:contentView subview:customView];
    [[self class] addEdgeConstraint:NSLayoutAttributeBottom superview:contentView subview:customView];*/
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

/*- (NSSize)preferredContentSize
{
    return NSMakeSize(500.f, 500.f);
}*/


@end
