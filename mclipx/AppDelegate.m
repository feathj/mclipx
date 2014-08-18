//
//  AppDelegate.m
//  mclipx
//
//  Created by Jonathan Featherstone on 7/19/14.
//  Copyright (c) 2014 ___FULLUSERNAME___. All rights reserved.
//

#import "AppDelegate.h"
#import "FMDatabase.h"

#import "MASShortcutView.h"
#import "MASShortcutView+UserDefaults.h"
#import "MASShortcut+UserDefaults.h"
#import "MASShortcut+Monitoring.h"

#import "MainWindowController.h"

NSString *const MASPreferenceKeyShortcut = @"MClipXShortcut";

@implementation AppDelegate {
    NSInteger lastChangeCount;
    NSPasteboard *pboard;
    FMDatabase *db;
    MainWindowController *mainWindow;
    
}

@synthesize shortcutView;
@synthesize statusMenu;
@synthesize statusItem;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Init globals
    [self initDB];
    pboard = [NSPasteboard generalPasteboard];
    
    // create tray icon
    statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    [statusItem setMenu:statusMenu];
    [statusItem setImage:[NSImage imageNamed:@"clipboard_16.png"]];
    
    // link up menu action(s)
    [[statusMenu itemWithTitle:@"Quit"] setAction:@selector(terminate:)];
    
    // create main window
    mainWindow = [[MainWindowController alloc] initWithWindowNibName:@"MainWindowController"];
    [mainWindow setDb:db];
    
    // register shortcut listener
    shortcutView.associatedUserDefaultsKey = MASPreferenceKeyShortcut;
    MASShortcut *shortcut = [MASShortcut shortcutWithKeyCode:kVK_ANSI_V modifierFlags:NSCommandKeyMask|NSShiftKeyMask];
    [MASShortcut addGlobalHotkeyMonitorWithShortcut:shortcut handler:^{
        [self hotkeyHit];
    }];

    // run polling timer for pasteboard changes
    [NSTimer scheduledTimerWithTimeInterval:0.25 target:self selector:@selector(pollPasteboard:) userInfo:nil repeats:YES];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // cleanup
    [db close];
}

- (void)initDB {
    db = [FMDatabase databaseWithPath:@"/tmp/tmp.db"];
    [db open];

    FMResultSet *s = [db executeQuery:@"SELECT name \
                      FROM sqlite_master \
                      WHERE type='table' \
                      AND name='pasteboard';"];
    if (![s next]){
        [db executeStatements:@"CREATE TABLE pasteboard( \
         id INTEGER PRIMARY KEY AUTOINCREMENT, \
         inferred_type VARCHAR(255), \
         pasteboard_text text, \
         timestamp DATETIME DEFAULT CURRENT_TIMESTAMP \
         );"];
    }
}

- (void)pollPasteboard:(NSTimer *)timer {
    NSInteger currentChangeCount = [pboard changeCount];
    
    if (currentChangeCount != lastChangeCount){
        lastChangeCount = currentChangeCount;
        [self pasteboardChanged:[pboard stringForType:NSPasteboardTypeString]];
    }
}

- (void)pasteboardChanged:(NSString *)pasteboardText {
    // create record in db
    // TODO: infer type
    NSString *inferredType = @"Python";
    NSDictionary *argsDict = [NSDictionary dictionaryWithObjectsAndKeys:pasteboardText, @"pasteboard_text", inferredType, @"inferred_type", nil];
    [db executeUpdate:@"INSERT INTO pasteboard(inferred_type,pasteboard_text) \
                        VALUES(:inferred_type,:pasteboard_text);" withParameterDictionary:argsDict];
}

- (void)hotkeyHit {
    NSRunningApplication *focusVictim = [[NSWorkspace sharedWorkspace] frontmostApplication];
    
    [mainWindow setFocusVictim:focusVictim];
    [NSApp activateIgnoringOtherApps:YES];
    [mainWindow.window setLevel:NSStatusWindowLevel];
    [mainWindow showWindow:self];
    [mainWindow focusSearch];
}

@end
