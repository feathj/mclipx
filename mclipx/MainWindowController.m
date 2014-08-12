//
//  MainWindowController.m
//  mclipx
//
//  Created by Jonathan Featherstone on 8/8/14.
//  Copyright (c) 2014 Jonathan Featherstone. All rights reserved.
//

#import "MainWindowController.h"

#import "FMDatabase.h"

@interface MainWindowController ()

@end

@implementation MainWindowController

@synthesize searchField;
@synthesize tableView;
@synthesize db;
@synthesize tableItems;

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        // Initialization code here.
        tableItems = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    
    [tableView setDataSource:self];
    [searchField setDelegate:self];
    
    // initial refresh
    [self refreshTable];
}

- (void)controlTextDidChange:(NSNotification *)notification {
    [self refreshTable];
}

- (BOOL)refreshTable {
    tableItems = [[NSMutableArray alloc] init];
    NSString *queryText = [NSString stringWithFormat:@"%%%@%%", [searchField stringValue]];
    FMResultSet *s = [db executeQuery:@"SELECT * \
                                        FROM pasteboard \
                                        WHERE pasteboard_text LIKE ? \
                                        ORDER BY id DESC \
                                        LIMIT 100",
                                        queryText];
    while ([s next]){
        [tableItems addObject:[s resultDictionary]];
    }
    [tableView reloadData];
    
    return YES;
}

- (int)numberOfRowsInTableView:(NSTableView *)aTableView {
    return [tableItems count];
    
}

- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(int)rowIndex {
//    // recycle cells
//    NSTextField *result = [tableView makeViewWithIdentifier:@"MainWindowController" owner:self];
//    if (result == nil) {
//        result = [[NSTextField alloc] init];
//        result.identifier = @"MainWindowController";
//    }
    
    
    // current record
    NSDictionary *currentRecord = [tableItems objectAtIndex:rowIndex];
    return [currentRecord objectForKey:@"pasteboard_text"];
    
//    result.stringValue = [currentRecord objectForKey:@"pasteboard_text"];
//    
//    return result;
}

@end
