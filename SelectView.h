//
//  selectView.h
//  selectInPic
//
//  Created by Fredrik Wallner on 2006-08-01.
//  Copyright 2006 Fredrik Wallner. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class SelectMarker;

@interface SelectView : NSImageView
{
	id selectionMarker;
}

- (void) mouseDown:(NSEvent *) theEvent;
- (void) mouseUp:(NSEvent *) theEvent;
- (void) mouseDragged:(NSEvent *) theEvent;
- (void) selectionChanged;
- (NSRect) getSelection;
- (void) setSelection:(NSRect) rect;
- (void) showSelector;
- (void) setSelectionMarker:(SelectMarker *) marker;
- (NSRect) getImageRect;

@end
