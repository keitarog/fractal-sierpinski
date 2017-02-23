
#import <Cocoa/Cocoa.h>
#import "MyOpenGLView.h"

#include "bridge.h"


@interface AppDelegate : NSObject<NSApplicationDelegate>

@property (weak, nonatomic) NSWindow *window;

@end


@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)notification {
	
	NSView *view = [[NSView alloc] init];
	[self.window setContentView:view];
	
	NSOpenGLPixelFormatAttribute *attr = (NSOpenGLPixelFormatAttribute *)GetDefaultCGLPixelFormatAttributes();
	NSOpenGLPixelFormat *format = [[NSOpenGLPixelFormat alloc] initWithAttributes:attr];

	MyOpenGLView *anOpenGLView = [[MyOpenGLView alloc] initWithFrame:view.bounds
		pixelFormat:format];
	anOpenGLView.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
	[view addSubview:anOpenGLView];
	
	NSLog(@"HELLO OBJC");

	[self.window makeKeyAndOrderFront:nil];
	[NSApp activateIgnoringOtherApps:YES];	
}


@end


int ApplicationMain() {
	@autoreleasepool {
		[NSApplication sharedApplication];
		[NSApp setActivationPolicy:NSApplicationActivationPolicyRegular];	
		
		NSMenu *mainMenu = [[NSMenu alloc] init];
		NSMenuItem *mainMenuItem = [[NSMenuItem alloc] init];
		NSMenu *appMenu = [[NSMenu alloc] init];
		[mainMenu addItem:mainMenuItem];
		[mainMenuItem setSubmenu:appMenu];	
		[NSApp setMainMenu:mainMenu];

		NSMenuItem *quitMenuItem = [[NSMenuItem alloc] initWithTitle:@"Quit Now!" 
								      action:@selector(terminate:)
								keyEquivalent:@"q"];
		[appMenu addItem:quitMenuItem];

		NSWindow *window = [[NSWindow alloc] initWithContentRect:NSMakeRect(0, 0, 400, 400)
						styleMask:NSTitledWindowMask backing:NSBackingStoreBuffered defer:NO];
		[window setTitle:@"HELLO WINDOW!"];
		[window cascadeTopLeftFromPoint:NSMakePoint(20, 20)];
		window.styleMask |= NSResizableWindowMask;
	
		static AppDelegate *delegate;
		delegate = [[AppDelegate alloc] init];
		delegate.window = window;

		[NSApp setDelegate:delegate];
		[NSApp run];
	}
	return 0;
}


