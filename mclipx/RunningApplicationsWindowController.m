//
//  RunningApplicationsWindowController.m
//  mclipx
//
//  Created by Jonathan Featherstone on 8/26/14.
//  Copyright (c) 2014 Jonathan Featherstone. All rights reserved.
//

#import "RunningApplicationsWindowController.h"

@interface RunningApplicationsWindowController ()

@end

@implementation RunningApplicationsWindowController{
}

@synthesize applicationTableView;
@synthesize okButton;

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        // Initialization code here.
    }
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    
    [[self applicationTableView] setDataSource:self];
}

- (int)numberOfRowsInTableView:(NSTableView *)aTableView {
    return (int)[[[NSWorkspace sharedWorkspace] runningApplications] count];
}

- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex {
    return [(NSRunningApplication*)[[[NSWorkspace sharedWorkspace] runningApplications] objectAtIndex:rowIndex] localizedName];
}

@end
