//
//  AppDelegate.h
//  mclipx
//
//  Created by Jonathan Featherstone on 7/19/14.
//  Copyright (c) 2014 ___FULLUSERNAME___. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class MASShortcutView;

@interface AppDelegate : NSObject <NSApplicationDelegate>

@property (assign) IBOutlet NSWindow *window;
@property (nonatomic, weak) IBOutlet MASShortcutView *shortcutView;
@property (nonatomic, weak) IBOutlet NSStatusItem *statusItem;

@end
