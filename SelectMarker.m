//
//  SelectMarker.m
//  selectInPic
//
//  Created by Fredrik Wallner on 2006-08-01.
//  Copyright 2006 Fredrik Wallner. All rights reserved.
//

#import "SelectMarker.h"

#define WHERE [target convertPoint:[theEvent locationInWindow] fromView:nil]


@implementation SelectMarker

+ selectMarkerForView:aView { return [[[self alloc] initWithView:aView] autorelease]; }

- initWithView:(NSView *) aView
  {
  if (self = [super init])
		{
		target = aView;
		[self setColor:[NSColor blueColor]];
		selectedPath = [[NSBezierPath bezierPath] retain];
		[self setSelectedRect:NSZeroRect];
		}
  return self;
  }

- (void) setColor:(NSColor *) aColor
	{
	[self setStrokeColor:aColor];
	[self setFillColor:[strokeColor colorWithAlphaComponent:0.2]];  //This really shouldn't be hard-coded...
	}
	
- (void) drawSelectMarker { [strokeColor set]; NSFrameRect(selectedRect); }

- (void) startMovingAtPoint:(NSPoint) where { trackingMode = trackMoving; lastLocation = where; }
- (void) startSelectingAtPoint:(NSPoint) where  { trackingMode = trackSelecting; lastLocation = where;  }

- (void) continueMovingAtPoint:(NSPoint) where
	{
	selectedRect.origin.x += where.x - lastLocation.x;
	selectedRect.origin.y += where.y - lastLocation.y;
	lastLocation = where;
	}

- (void) stopMovingAtPoint:(NSPoint) where
	{
	[self continueMovingAtPoint:where];
	trackingMode = trackNone;
	}
	
- (void) continueSelectingAtPoint:(NSPoint) where { selectedRect = rectFromPoints(lastLocation,where); }
  
- (void) stopSelectingAtPoint:(NSPoint) where 
	{ 
	selectedRect = rectFromPoints(lastLocation,where);  
	trackingMode = trackNone;
	}

	// CropMarker isn't an NSResponder subclass, but it still cares about mouse events.
- (void) mouseDown:(NSEvent *) theEvent 
	{ 
	lastLocation = WHERE;
	if (NSPointInRect(lastLocation, selectedRect))
			{
			[self startMovingAtPoint:lastLocation]; 
			return;
			}
	[self startSelectingAtPoint:lastLocation];
	}
	
- (void) mouseUp:(NSEvent *) theEvent 
	{ 
	switch (trackingMode)
		{
		case trackSelecting:
			[self stopSelectingAtPoint:WHERE];
			break;
			
		case trackMoving:
			[self stopMovingAtPoint:WHERE];
			break;
		
		default:	
			NSLog (@"Bad tracking mode in [CropMarker mouseUp]");
		}
	}
	
- (void) mouseDragged:(NSEvent *) theEvent 
	{ 
	switch (trackingMode)
		{
		case trackSelecting:
			[self continueSelectingAtPoint:WHERE];
			break;
			
		case trackMoving:
			[self continueMovingAtPoint:WHERE];
			break;
		
		default:	
			NSLog (@"Bad tracking mode in [CropMarker mouseDragged]");
		}
	}
  
- (void) dealloc
  {
  if (fillColor) [fillColor release];
  if (strokeColor) [strokeColor release];
  [super dealloc];
  }
  
	// Accessors and other one-liners.
- (void) setFillColor:(NSColor *) color { [color retain]; [fillColor release]; fillColor = color; }
- (void) setStrokeColor:(NSColor *) color { [color retain]; [strokeColor release]; strokeColor = color; }
- (NSBezierPath *) selectedPath {  return [NSBezierPath bezierPathWithRect:selectedRect];}
- (NSRect) selectedRect 	{ return selectedRect; }
- (void) setSelectedRect:(NSRect) rect { selectedRect = rect;}
- (void) setSelectedRectOrigin:(NSPoint) where { selectedRect.origin = where;}
- (void) setSelectedRectSize:(NSSize) size { selectedRect.size = size;}
- (void) moveSelectedRectBy:(NSSize) delta { selectedRect.origin.x += delta.width; selectedRect.origin.y += delta.height;}

@end

NSRect rectFromPoints(NSPoint p1, NSPoint p2)  // Given two corners, make an NSRect.
  {
  return 
    NSMakeRect( MIN(p1.x, p2.x), 
                MIN(p1.y, p2.y), 
                fabs(p1.x - p2.x), 
                fabs(p1.y - p2.y));
  }

