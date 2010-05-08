//
//  SelectMarker.h
//  selectInPic
//
//  Created by Fredrik Wallner on 2006-08-01.
//  Copyright 2006 Fredrik Wallner. All rights reserved.
//

#import <Cocoa/Cocoa.h>

typedef enum _SelectionTrackingMode
	{
	trackNone,
	trackSelecting,
	trackMoving,
	trackResizing  // Not implemented!  (Currently left as an exercise for the reader, but I may fill this in someday.)
	} SelectionTrackingMode;


@interface SelectMarker : NSObject
{
	NSView *target;
	BOOL selecting, dragging, resizing;
	NSRect selectedRect;
	NSPoint lastLocation;
	NSColor *fillColor, *strokeColor;
	SelectionTrackingMode trackingMode;
	NSBezierPath *selectedPath;
}

	// Convenience constructor.  Use this in most cases.
+ selectMarkerForView:aView;

	// Designated Intiailizer
- initWithView:(NSView *) aView;

- (void) drawSelectMarker;

	// The mouse-tracking methods
- (void) startSelectingAtPoint:(NSPoint) where;
- (void) continueSelectingAtPoint: (NSPoint) where;
- (void) stopSelectingAtPoint:(NSPoint) where;
- (void) startMovingAtPoint:(NSPoint) where;
- (void) continueMovingAtPoint: (NSPoint) where;
- (void) stopMovingAtPoint:(NSPoint) where;

- (void) mouseDown:(NSEvent *) theEvent;
- (void) mouseUp:(NSEvent *) theEvent;
- (void) mouseDragged:(NSEvent *) theEvent;

 // Simple Accessors
- (void) setColor:(NSColor *) color;
- (void) setFillColor:(NSColor *) color;
- (void) setStrokeColor:(NSColor *) color;
- (NSBezierPath *) selectedPath;
- (NSRect) selectedRect;
- (void) setSelectedRect:(NSRect) rect;
- (void) setSelectedRectOrigin:(NSPoint) where;
- (void) setSelectedRectSize:(NSSize) size;
- (void) moveSelectedRectBy:(NSSize) delta;


@end

NSRect rectFromPoints(NSPoint p1, NSPoint p2);