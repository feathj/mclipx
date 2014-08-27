//
//  PreferencesWindowController.m
//  mclipx
//
//  Created by Jonathan Featherstone on 8/26/14.
//  Copyright (c) 2014 Jonathan Featherstone. All rights reserved.
//

#import "PreferencesWindowController.h"

#import "RunningApplicationsWindowController.h"

@interface PreferencesWindowController ()

@end

@implementation PreferencesWindowController {
        RunningApplicationsWindowController * runningApplicationsWindow;
}

@synthesize exclusionTableView;
@synthesize addRemoveExclusions;

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
    
    // init
    runningApplicationsWindow = [[RunningApplicationsWindowController alloc] initWithWindowNibName:@"RunningApplicationsWindowController"];
    
    // register data sources and delegates
    [[self exclusionTableView] setDataSource:self];
    [[self addRemoveExclusions] setAction:@selector(addRemoveAction:)];
    
    
    // Defaults
    NSDictionary *appDefaults = [NSDictionary dictionaryWithObject:[[NSMutableArray alloc] init] forKey:@"ExclusionApps"];
    [[NSUserDefaults standardUserDefaults] registerDefaults:appDefaults];
    
}

- (void)addRemoveAction:(id)sender {
    [runningApplicationsWindow showWindow:self];
}

- (int)numberOfRowsInTableView:(NSTableView *)aTableView {
    return (int)[[[NSUserDefaults standardUserDefaults] arrayForKey:@"ExclusionApps"] count];
}

- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex {
    return [[[NSUserDefaults standardUserDefaults] arrayForKey:@"ExclusionApps"] objectAtIndex:rowIndex];
}

@end
