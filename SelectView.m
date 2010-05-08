//
//  selectView.m
//  selectInPic
//
//  Created by Fredrik Wallner on 2006-08-01.
//  Copyright 2006 Fredrik Wallner. All rights reserved.
//

#import "SelectView.h"
#import "SelectMarker.h"

@implementation NSImageCell (SelectView)

- (NSRect) rectCoveredByImageInBounds:(NSRect) bounds
	// This is a work-around to deal with the fact that NSImageCell won't tell me the rectangle *actually* covered by its image, but NSCell will.
{
	return [super imageRectForBounds:bounds];
}

@end

@implementation SelectView

- (void) mouseDown:(NSEvent *) theEvent { [selectionMarker mouseDown:theEvent]; }

- (void) mouseUp:(NSEvent *) theEvent 
	{ 
	[selectionMarker mouseUp:theEvent]; 
	[self selectionChanged];
//	[self postSelectionChangedNotification];  // This is how the controller knows to redraw the second NSImageView.
	}
	
- (void) mouseDragged:(NSEvent *) theEvent 
	{ 
	[selectionMarker mouseDragged:theEvent]; 
	[self selectionChanged];	
	}

- (void) selectionChanged 	{ [self setNeedsDisplay:YES]; }

- (NSRect) getSelection
{
	return [selectionMarker selectedRect];
}

- (void) showSelector
{
	[self setSelectionMarker:[SelectMarker selectMarkerForView:self]]; 
}

- (void) setSelectionMarker:(SelectMarker *) marker  // Should be a CropMarker or a subclass thereof, but I'm not in the mood for strong typing..
	{
	[marker retain];
	[selectionMarker release];
	selectionMarker = marker;
	}

- (void)drawRect:(NSRect)rect 
  {
  [super drawRect:rect];
	[selectionMarker drawSelectMarker];
  }

- (void) setSelection:(NSRect)rect
{
	[selectionMarker setSelectedRect:rect];
}

- (NSRect) getImageRect
{
	return [[self cell] rectCoveredByImageInBounds:[self bounds]];
}

@end
