/* MyProgressPanel */

#import <Cocoa/Cocoa.h>

@interface MyProgressPanel : NSPanel
{
    IBOutlet NSProgressIndicator *bar;
    IBOutlet NSTextField *text;
	NSFileHandle *fileHandle;
	NSObject *parent;
}

+ progressPanelForFile:aFileHandle andController:anObject; // Convenience constructor

- initWithFile:(NSFileHandle *) aFileHandle andController:(NSObject *)anObject;

- (void) updateText:(NSString *) newText;
- (void) update:(float) value;
- (void) makeIndetermined;


@end
