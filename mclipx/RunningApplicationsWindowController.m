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
@synthesize cancelButton;

@synthesize chosenApp;

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
    
    // set delegate for table
    [applicationTableView setDataSource:self];

    // register events
    [okButton setAction:@selector(okButtonClickEvent:)];
    [cancelButton setAction:@selector(cancelButtonClickEvent:)];

    // select first row in app list table
    NSIndexSet *indexSet = [NSIndexSet indexSetWithIndex:0];
    [applicationTableView selectRowIndexes:indexSet byExtendingSelection:NO];
    [self.window makeFirstResponder:applicationTableView];
}

- (int)numberOfRowsInTableView:(NSTableView *)aTableView {
    return (int)[[[NSWorkspace sharedWorkspace] runningApplications] count];
}

- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex {
    return [(NSRunningApplication*)[[[NSWorkspace sharedWorkspace] runningApplications] objectAtIndex:rowIndex] localizedName];
}

-(void) okButtonClickEvent:(id) sender {
    chosenApp = [(NSRunningApplication*)[[[NSWorkspace sharedWorkspace] runningApplications] objectAtIndex:[applicationTableView selectedRow]] localizedName];
    [self close];
}

-(void) cancelButtonClickEvent:(id) sender {
    chosenApp = nil;
    [self close];
}

@end
