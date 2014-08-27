//
//  PreferencesWindowController.h
//  mclipx
//
//  Created by Jonathan Featherstone on 8/26/14.
//  Copyright (c) 2014 Jonathan Featherstone. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface PreferencesWindowController : NSWindowController
@property (weak) IBOutlet NSTableView *exclusionTableView;
@property (weak) IBOutlet NSSegmentedControl *addRemoveExclusions;

@end
