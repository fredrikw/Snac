#import "MyProgressPanel.h"

@implementation MyProgressPanel

+ progressPanelForFile:aFileHandle andController:anObject{ return [[[self alloc] initWithFile:aFileHandle andController:anObject] autorelease]; }

- initWithFile:(NSFileHandle *) aFileHandle andController:(NSObject *) anObject
{
	if (self = [super init])
	{
		fileHandle = aFileHandle;
		parent = anObject;
	}
	return self;
}


- (void) updateText:(NSString *) newText
{
	[text setStringValue:newText];
}

- (void) update:(float) value
{
	if([bar isIndeterminate])
		[bar setIndeterminate:NO];
	[bar setDoubleValue:(double) value];
}

- (void) makeIndetermined
{
	[bar setIndeterminate:YES];
	[bar startAnimation:self];
}

@end
