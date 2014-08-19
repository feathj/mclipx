//
//  MainWindowController.m
//  mclipx
//
//  Created by Jonathan Featherstone on 8/8/14.
//  Copyright (c) 2014 Jonathan Featherstone. All rights reserved.
//

#import "MainWindowController.h"

#import "FMDatabase.h"
#import "MGSFragaria.h"

@interface MainWindowController ()

@end

@implementation MainWindowController

@synthesize searchField;
@synthesize tableView;
@synthesize db;
@synthesize tableItems;
@synthesize focusVictim;

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        // Initialization code here.
        tableItems = [[NSMutableArray alloc] init];
    }
    return self;
}

// Handle textView commands to allow down arrow to focus table and escape to close
- (BOOL)control:(NSControl *)control textView:(NSTextView *)fieldEditor doCommandBySelector:(SEL)commandSelector {
    if (commandSelector == @selector(moveDown:)){
        [self.window makeFirstResponder: tableView];
        NSIndexSet *indexSet = [NSIndexSet indexSetWithIndex:0];
        [tableView selectRowIndexes:indexSet byExtendingSelection:NO];
    } else if (commandSelector == @selector(cancelOperation:)){
        [self closeAndRefocus];
    }
    return NO;
}

// Escape to close in table delegate
- (void)cancelOperation:(id)sender {
    [self closeAndRefocus];
}

-(void)focusSearchWithCharacters:(NSString*)characters {
    [self.window makeFirstResponder: searchField];
    if (characters){
        [searchField setStringValue:characters];
        [[searchField currentEditor] moveToEndOfLine:nil];
        [self refreshTable];
    }
}

- (void)keyDown:(NSEvent *)theEvent {
    if (theEvent.keyCode == 36){
        [self itemChosen: [tableView selectedRow]];
    } else {
        [self focusSearchWithCharacters:theEvent.characters];
    }
}

- (void)closeAndRefocus {
    [self close];
    [[self focusVictim] activateWithOptions:NSApplicationActivateIgnoringOtherApps];
}

- (void)itemChosen:(NSInteger)row {
    NSDictionary *currentRecord = [tableItems objectAtIndex:row];

    // remove chosen record so it bubbles up to top as most recent
    [db executeUpdate:@"DELETE FROM pasteboard WHERE id = ?", [NSNumber numberWithInt:[[currentRecord valueForKey:@"id"] intValue]]];

    NSPasteboard *pasteBoard = [NSPasteboard generalPasteboard];
    [pasteBoard clearContents];
    [pasteBoard setString:[currentRecord objectForKey:@"pasteboard_text"] forType:NSPasteboardTypeString];
    
    [self close];
    [[self focusVictim] activateWithOptions:NSApplicationActivateIgnoringOtherApps];
    sleep(1);
    [self runPaste];
}

- (void)runPaste {
    CGEventSourceRef sourceRef = CGEventSourceCreate(kCGEventSourceStateCombinedSessionState);
    if (!sourceRef){
        NSLog(@"No event source");
        return;
    }
    CGEventRef eventDown = CGEventCreateKeyboardEvent(sourceRef, (CGKeyCode)9, true);
    CGEventSetFlags(eventDown, kCGEventFlagMaskCommand);
    CGEventRef eventUp = CGEventCreateKeyboardEvent(sourceRef, (CGKeyCode)9, false);
    CGEventPost(kCGHIDEventTap, eventDown);
    CGEventPost(kCGHIDEventTap, eventUp);
    CFRelease(eventDown);
    CFRelease(eventUp);
    CFRelease(sourceRef);
}


- (void)windowDidLoad {
    [super windowDidLoad];
    
    [tableView setDataSource:self];
    [tableView setDelegate:self];
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

-(NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    // create view (TODO: recycle)
    NSTextView *result = [[NSTextView alloc] init];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle setLineBreakMode:NSLineBreakByTruncatingTail];
    [result setDefaultParagraphStyle:paragraphStyle];
    
    // pull current record
    NSDictionary *currentRecord = [tableItems objectAtIndex:row];
    NSArray *textLines = [[currentRecord objectForKey:@"pasteboard_text"] componentsSeparatedByString:@"\n"];
    
    [result setString:[textLines objectAtIndex:0]];
    
    return result;
}

@end
