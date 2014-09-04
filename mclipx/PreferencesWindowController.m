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
    [exclusionTableView setDataSource:self];
    [addRemoveExclusions setAction:@selector(addRemoveAction:)];
    
    // Defaults
    NSDictionary *appDefaults = [NSDictionary dictionaryWithObject:[[NSMutableArray alloc] init] forKey:@"ExclusionApps"];
    [[NSUserDefaults standardUserDefaults] registerDefaults:appDefaults];
    
}

- (void)runningApplicationWindowWillClose:(NSNotification *)notification {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    if (runningApplicationsWindow.chosenApp){
        NSMutableArray *newList = [NSMutableArray arrayWithArray:[[NSUserDefaults standardUserDefaults] arrayForKey:@"ExclusionApps"]];
        [newList addObject:runningApplicationsWindow.chosenApp];
        [[NSUserDefaults standardUserDefaults] setObject:newList forKey:@"ExclusionApps"];
        [exclusionTableView reloadData];
    }
}

- (void)addRemoveAction:(id)sender {
    if (addRemoveExclusions.selectedSegment == 0){ // ADD
        // register close running applications window
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(runningApplicationWindowWillClose:) name:NSWindowWillCloseNotification object:runningApplicationsWindow.window];
        [runningApplicationsWindow showWindow:self];
    } else if (addRemoveExclusions.selectedSegment == 1) { // REMOVE
        NSMutableArray *newList = [NSMutableArray arrayWithArray:[[NSUserDefaults standardUserDefaults] arrayForKey:@"ExclusionApps"]];
        [newList removeObjectAtIndex:[exclusionTableView selectedRow]];
        [[NSUserDefaults standardUserDefaults] setObject:newList forKey:@"ExclusionApps"];
        [exclusionTableView reloadData];
    } else {
    }
}

- (int)numberOfRowsInTableView:(NSTableView *)aTableView {
    return (int)[[[NSUserDefaults standardUserDefaults] arrayForKey:@"ExclusionApps"] count];
}

- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex {
    return [[[NSUserDefaults standardUserDefaults] arrayForKey:@"ExclusionApps"] objectAtIndex:rowIndex];
}

@end
