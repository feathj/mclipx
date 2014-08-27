//
//  RunningApplicationsWindowController.h
//  mclipx
//
//  Created by Jonathan Featherstone on 8/26/14.
//  Copyright (c) 2014 Jonathan Featherstone. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface RunningApplicationsWindowController : NSWindowController
@property (weak) IBOutlet NSTableView *applicationTableView;
@property (weak) IBOutlet NSButton *okButton;

@end
