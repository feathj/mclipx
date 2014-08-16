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

- (BOOL)control:(NSControl *)control textView:(NSTextView *)fieldEditor doCommandBySelector:(SEL)commandSelector {
    if (commandSelector == @selector(moveDown:)){
        [self.window makeFirstResponder: tableView];
    } else if (commandSelector == @selector(cancelOperation:)){
        [self close];
    }
    return NO;
}

-(void)focusSearch{
    [self.window makeFirstResponder: searchField];
}

- (void)keyDown:(NSEvent *)theEvent {
    if (theEvent.keyCode == 36){
        [self itemChosen: [tableView selectedRow]];
    }
}

- (void)itemChosen:(NSInteger)row {
    NSDictionary *currentRecord = [tableItems objectAtIndex:row];
    NSPasteboard *pasteBoard = [NSPasteboard generalPasteboard];
    [pasteBoard clearContents];
    [pasteBoard setString:[currentRecord objectForKey:@"pasteboard_text"] forType:NSPasteboardTypeString];
    
    [self close];
    [[self focusVictim] activateWithOptions:NSApplicationActivateIgnoringOtherApps];
    sleep(1);
    [self runPaste];
}

- (void)runPaste{
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
