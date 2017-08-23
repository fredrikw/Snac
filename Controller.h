//
//  controller.h
//  selectInPic
//
//  Created by Fredrik Wallner on 2006-07-31.
//  Copyright 2006 Fredrik Wallner. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class MyProgressPanel;

typedef enum _scantypes
{
	previewScan,
	finalScan,
	cancelScan
} scantypes;

@interface Controller : NSObject 
{
	IBOutlet id imageView;
	IBOutlet NSPopUpButton *mode;
	IBOutlet NSPopUpButton *format;
	IBOutlet NSPopUpButton *res;
	IBOutlet NSPopUpButton *depth;
	IBOutlet NSButton *previewButton, *scanButton;
	NSFileHandle *imageFileHandle, *resultsHandle;
	NSImage *previewImage;
	scantypes scantype;
	IBOutlet MyProgressPanel *progress;
	IBOutlet NSWindow *errorWindow;
	IBOutlet NSTextField *errorText;
	IBOutlet NSButton *openHelper;
	NSString *errorString;
	float imagewidth;
	float imageheight;
	float scaling;
}

- (IBAction)preview:(id)sender;
- (IBAction)scan:(id)sender;
- (void)saveImage;
- (IBAction)cancel:(id)sender;
- (IBAction)selectAll:(id)sender;
- (void)nstaskExceptionTriggered:(NSException *)exception;
- (void)dataArrived:(NSNotification *) notification;
- (void)setupFromDefaults:(NSNotification *) notification;
- (void) showProgress;
- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)app;
- (IBAction)goToHomepage:sender;

@end
