//
//  controller.m
//  selectInPic
//
//  Created by Fredrik Wallner on 2006-07-31.
//  Copyright 2006 Fredrik Wallner. All rights reserved.
//

#import "Controller.h"
#import "SelectView.h"
#import "MyProgressPanel.h"
#import "FWPrefs.h"

@implementation Controller

- (void) awakeFromNib
{
	/* Load factory defaults */
	[FWPrefs loadDefaults];
	
	/* Customize the popups */
	[self setupFromDefaults:nil];
	
	NSSize size;
//	NSRect viewRect = [imageView getDrawRect];
	NSRect viewRect = [[imageView cell] drawingRectForBounds:[imageView bounds]];
	
	scaling = MIN((viewRect.size.width-6) / imagewidth, (viewRect.size.height-6) / imageheight);
	scaling = (float)truncf(scaling*100.0)/100.0;
	size.width=imagewidth * scaling;
	size.height=imageheight * scaling;
	NSString *previewPath = [[[NSBundle mainBundle] resourcePath]stringByAppendingPathComponent:@"preview.tiff"];
	
	/* Load a previous preview and resize */
	previewImage = [[NSImage alloc] initByReferencingFile:previewPath];
	[imageView setImage:previewImage];
	[[imageView image] setScalesWhenResized:TRUE];

	[[imageView image] setSize:size];
	[imageView showSelector];
	
	/* Start notifications */
	[[NSNotificationCenter defaultCenter] 
		addObserver:self 
		   selector:@selector(dataArrived:) 
			   name:@"NSFileHandleReadCompletionNotification"
			 object:nil];

	[[NSNotificationCenter defaultCenter] 
		addObserver:self 
		   selector:@selector(setupFromDefaults:) 
			   name:@"FWPrefsChanged"
			 object:nil];
	
}
	
- (IBAction)preview:(id)sender
{
	NSTask *scanimage = [[NSTask alloc] init];
	NSMutableArray *args = [NSMutableArray array];
	NSString* imagePath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"preview.tiff"];
	NSFileManager *fm = [NSFileManager defaultManager];

	/* Set the scanmode to preview */
	scantype = previewScan;
	
	/* Disable the buttons during the scan */
	[previewButton setEnabled:NO];
	[scanButton setEnabled:NO];
	
	/* Reset errors */
	errorString = @"";
	
	[self showProgress];
	
	/* Handle the temp-files to cope with error during scan */
	if([fm fileExistsAtPath:[imagePath stringByAppendingString:@".bak"]])
		[fm removeFileAtPath:[imagePath stringByAppendingString:@".bak"] handler:nil];
	[fm movePath:imagePath toPath:[imagePath stringByAppendingString:@".bak"] handler:nil];
	[fm createFileAtPath:imagePath contents:nil attributes:nil];

	imageFileHandle = [NSFileHandle fileHandleForWritingAtPath:imagePath];
		
    /* set arguments */
    [args addObject:@"--format=tiff"];

	// Resolution
    [args addObject:[[NSUserDefaults standardUserDefaults] stringForKey:@"res_option"]]; 
	[args addObject: [res itemTitleAtIndex:0]];
	// Size
    [args addObject:[[NSUserDefaults standardUserDefaults] stringForKey:@"width"]]; 
	[args addObject:[[NSUserDefaults standardUserDefaults] stringForKey:@"max_x"]];
    [args addObject:[[NSUserDefaults standardUserDefaults] stringForKey:@"height"]];
	[args addObject:[[NSUserDefaults standardUserDefaults] stringForKey:@"max_y"]];
	// Mode
    [args addObject:[[NSUserDefaults standardUserDefaults] stringForKey:@"mode_option"]]; 
	[args addObject:[mode titleOfSelectedItem]];
	[args addObject:@"-p"];

	/* Add pipe on stderr to follow the progress */
	NSPipe *pipe = [[NSPipe alloc] init];
	[scanimage setStandardError:pipe];
	NSFileHandle *handle = [pipe fileHandleForReading];
	[handle readInBackgroundAndNotify];
	
	/* start scan */
	[scanimage setStandardOutput:imageFileHandle];
	[scanimage setLaunchPath:[[NSUserDefaults standardUserDefaults] stringForKey:@"scanimagePath"]];
	[scanimage setArguments:args];
	[scanimage launch];	
}

- (IBAction)scan:(id)sender
{
	NSTask *scanimage = [[NSTask alloc] init];
	NSMutableArray *args = [NSMutableArray array];
	NSRect selection;
	NSRect viewRect;
	float x, y, selWidth, selHeight;
	NSString* imagePath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"scan.tiff"];
	NSFileManager *fm = [NSFileManager defaultManager];

	/* Set the scanmode to final */
	scantype = finalScan;

	/* Disable the buttons during the scan */
	[previewButton setEnabled:NO];
	[scanButton setEnabled:NO];
	
	/* Reset errors */
	errorString = @"";
	
	/* Handle the temp-files */
	if([fm fileExistsAtPath:imagePath])
		[fm removeFileAtPath:imagePath handler:nil];
	[fm createFileAtPath:imagePath contents:nil attributes:nil];
	
	imageFileHandle = [NSFileHandle fileHandleForWritingAtPath:imagePath];
	
    /* set arguments */
    [args addObject:[[NSString stringWithString:@"--format="] stringByAppendingString:[[format titleOfSelectedItem] lowercaseString]]];
    [args addObject:@"--resolution"]; 
	[args addObject:[res titleOfSelectedItem]];
	[args addObject:@"--mode"];
	[args addObject:[mode titleOfSelectedItem]];
	[args addObject:@"-p"];
	
	/* get selected area */
	viewRect = [imageView bounds];
	selection = [imageView getSelection];
	selHeight = selection.size.height;
	selWidth = selection.size.width;
/*
	rect.origin.x = ((viewRect.size.width) - (imagewidth * scaling))/2;
	rect.origin.y = ((viewRect.size.height) - (imageheight * scaling))/2;
	rect.size.width = (imagewidth * scaling);
	rect.size.height = (imageheight * scaling);
*/
	x=selection.origin.x - (viewRect.size.width - imagewidth * scaling)/2;
	y=viewRect.size.height - (selection.origin.y + selHeight) - (viewRect.size.height - (imageheight * scaling))/2;
	if(x < 0.0)
	{
		selWidth += x;
		x = 0.0;
	}
	if(y < 0.0)
	{
		selHeight += y;
		y = 0.0;
	}
	if((x + selWidth) > (imagewidth * scaling))
		selWidth = (imagewidth * scaling) - x;
	if((y + selHeight) > (imageheight * scaling))
		selHeight = (imageheight * scaling) - y;
	if((selHeight <= 0) || (selWidth <= 0))
	{
		x = 0.0;
		y = 0.0;
		selHeight = imageheight;
		selWidth = imagewidth;
		[self selectAll:nil];
	}
	else
	{
		x /= scaling;
		y /= scaling;
		selHeight /= scaling;
		selWidth /= scaling;
	}
	[self showProgress];
	
	/* add selected area to arguments */
	[args addObject:[NSString stringWithFormat:@"-t %1.0f", y]];
	[args addObject:[NSString stringWithFormat:@"-l %1.0f", x]];
	[args addObject:[NSString stringWithFormat:@"-x %1.0f", selWidth]];
	[args addObject:[NSString stringWithFormat:@"-y %1.0f", selHeight]];
	
	/* Add pipe on stderr to follow the progress */
	NSPipe *pipe = [[NSPipe alloc] init];
	[scanimage setStandardError:pipe];
	NSFileHandle *handle = [pipe fileHandleForReading];
	[handle readInBackgroundAndNotify];
	
	/* start scan */
	[scanimage setStandardOutput:imageFileHandle];
	[scanimage setLaunchPath:@"/usr/local/bin/scanimage"];
	[scanimage setArguments:args];
	[scanimage launch];
}

-(id)init
{
	self = [super init];
	[[NSNotificationCenter defaultCenter] addObserver:self 
											 selector:@selector(taskEnded:) 
												 name:NSTaskDidTerminateNotification 
											   object:nil];
	return self;
}

- (void)taskEnded:(NSNotification *)aNotification
{
	int status = [[aNotification object] terminationStatus];
	[progress close];
	if(scantype != cancelScan)
	{
		if (status == 0) 
		{
			NSLog(@"Task succeeded.");
			if(scantype == previewScan)
			{
				/* Load the preview and resize */
				NSSize size;
				size.width=(imagewidth * scaling);
				size.height=(imageheight * scaling);
				
				[previewImage release];
				previewImage = [[NSImage alloc] initByReferencingFile:[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"preview.tiff"]];
				[imageView setImage:previewImage];
				[[imageView image] setScalesWhenResized:TRUE];
				[[imageView image] setSize:size];
			}
			else
				[self saveImage];
		}
		else
		{
			NSLog(@"Task failed.");
			[errorWindow makeKeyAndOrderFront:self];
			[errorWindow setLevel:NSStatusWindowLevel];
			[errorText setStringValue:errorString];
			if(scantype == previewScan)
			{
				NSString* imagePath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"preview.tiff"];
				NSFileManager *fm = [NSFileManager defaultManager];
				
				/* Handle the temp-files to cope with error during scan */
				if([fm fileExistsAtPath:imagePath])
					[fm removeFileAtPath:imagePath handler:nil];
				[fm movePath:[imagePath stringByAppendingString:@".bak"] toPath:imagePath handler:nil];
			}
		}
	}
	if (imageFileHandle != nil)
	{
		[imageFileHandle release];
		imageFileHandle = nil;
	}

	/* Enable the buttons after the scan */
	[previewButton setEnabled:YES];
	[scanButton setEnabled:YES];
	
}

- (void)saveImage
{
	NSSavePanel *sp;
	int runResult;
	
	/* create or get the shared instance of NSSavePanel */
	sp = [NSSavePanel savePanel];
	
	/* set up new attributes */
	[sp setRequiredFileType:[[format titleOfSelectedItem] lowercaseString]];
	[sp setCanSelectHiddenExtension:YES];

	/* display the NSSavePanel */
	runResult = [sp runModalForDirectory:nil file:@""];
	
	/* if successful, save file under designated name */
	if (runResult == NSOKButton)
	{
		NSFileManager *fm = [NSFileManager defaultManager];
		
		/* Copy the temp-file to the "save-location" */
		if([fm fileExistsAtPath:[sp filename]])
			[fm removeFileAtPath:[sp filename] handler:nil];
		[fm movePath:[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"scan.tiff"] toPath:[sp filename] handler:nil];
		
		/* Optionally open in external application */
		if([openHelper state] == NSOnState)
		{
			[[NSWorkspace sharedWorkspace] openFile:[sp filename] withApplication:[[NSUserDefaults standardUserDefaults] stringForKey:@"helperPath"]];
		}
				
	}
}

- (IBAction)cancel:(id)sender
{
	[progress close];
	NSTask *scanimage = [[NSTask alloc] init];
	NSMutableArray *args = [NSMutableArray array];
	
	/* Set the scanmode to cancel */
	scantype = cancelScan;

	[args addObject:@"-n"];
	
	/* start scan */
	[scanimage setLaunchPath:@"/usr/local/bin/scanimage"];
	[scanimage setArguments:args];
	[scanimage launch];	
	
}

- (void)dataArrived:(NSNotification *) notification
{
	// http://forums.macnn.com/archive/index.php/t-267936.html 	
	// Get output string
	NSData *data = [[notification userInfo] objectForKey:@"NSFileHandleNotificationDataItem"];
	NSString *string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
	if ([data length] > 0) 
	{	
		/* Try to parse the data, finds the last :***% pair in the string */
		NSRange range;
		NSRange rangeTemp = [string rangeOfString:@"%" options:NSBackwardsSearch];
		if(rangeTemp.location != NSNotFound)
		{
			range.location = 0;
			range.length = rangeTemp.location;
			rangeTemp = [string rangeOfString:@":" options:NSBackwardsSearch range:range];
			if(rangeTemp.location != NSNotFound)
			{			
				range.location = rangeTemp.location + 2;
				range.length -= range.location;
				float prog = [[string substringWithRange:range] floatValue];
				[progress update:prog];
				[progress updateText:@"Scanning"];
			}
		}
		else
			errorString = [errorString stringByAppendingString:string];
		// Ask for another notification
		[[notification object] readInBackgroundAndNotify];
	}
	[string release];	
}

- (IBAction)selectAll:(id)sender
{
	NSRect viewRect = [imageView bounds];
	NSRect rect;
	rect.origin.x = ((viewRect.size.width) - (imagewidth * scaling))/2;
	rect.origin.y = ((viewRect.size.height) - (imageheight * scaling))/2;
	rect.size.width = (imagewidth * scaling);
	rect.size.height = (imageheight * scaling);
	[imageView setSelection:rect];
	[imageView setNeedsDisplay:YES];
}

- (void) showProgress
{
	/* Start the progressbar */
	[progress makeKeyAndOrderFront:self];
	[progress setHidesOnDeactivate:NO];
	[progress updateText:@"Initializing"];
	[progress makeIndetermined];
	[progress setLevel:NSStatusWindowLevel];
}	

- (void)setupFromDefaults:(NSNotification *) notification
{
	/* Read the defaults and initialize variables and popups */
//	depth_option
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSString *tempString = [defaults stringForKey:@"depths"];
	NSString *aString;
	[depth removeAllItems];
	NSArray *tempArray = [tempString componentsSeparatedByString:@","];
	NSEnumerator *enumerator = [tempArray objectEnumerator];
	while(aString = [enumerator nextObject])
	{
		[depth addItemWithTitle:[aString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]];
	}
//	height;
	imagewidth = [[defaults stringForKey:@"max_x"] floatValue];
	imageheight = [[defaults stringForKey:@"max_y"] floatValue];
//	mode_option;
	tempString = [defaults stringForKey:@"modes"];
	[mode removeAllItems];
	tempArray = [tempString componentsSeparatedByString:@","];
	enumerator = [tempArray objectEnumerator];
	while(aString = [enumerator nextObject])
	{
		[mode addItemWithTitle:[aString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]];
	}
//	res_option;
	tempString = [defaults stringForKey:@"resolutions"];
	[res removeAllItems];
	tempArray = [tempString componentsSeparatedByString:@","];
	enumerator = [tempArray objectEnumerator];
	while(aString = [enumerator nextObject])
	{
		[res addItemWithTitle:[aString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]];
	}
//	top_left_x;
//	top_left_y;
//	width;
	if([defaults boolForKey:@"openHelper"] == YES)
		[openHelper setState:NSOnState];
	else
		[openHelper setState:NSOffState];
	
}

- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)app
{
	/* Save the openHelper state to the defaults */
	if([openHelper state] == NSOnState)
		[[NSUserDefaults standardUserDefaults] setObject:@"YES" forKey:@"openHelper"];
	else
		[[NSUserDefaults standardUserDefaults] setObject:@"NO" forKey:@"openHelper"];
		
	/* Synchronise the defaults */
	[[NSUserDefaults standardUserDefaults] synchronize];
	return NSTerminateNow;
}

- (void)windowWillClose:(NSNotification *)aNotification
{
	[NSApp terminate:self];
}

- (IBAction)goToHomepage:sender;
{
	[[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"http://www.wallner.nu/fredrik/software/snac/"]];
}


@end

