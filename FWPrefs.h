/* FWPrefs */

#import <Cocoa/Cocoa.h>

@interface FWPrefs : NSObject
{
    IBOutlet NSTextField *depth_option;
    IBOutlet NSTextField *depths;
    IBOutlet NSTextField *height;
    IBOutlet NSTextField *max_x;
    IBOutlet NSTextField *max_y;
    IBOutlet NSTextField *mode_option;
    IBOutlet NSTextField *modes;
    IBOutlet NSTextField *res_option;
    IBOutlet NSTextField *resolutions;
    IBOutlet NSTextField *top_left_x;
    IBOutlet NSTextField *top_left_y;
    IBOutlet NSTextField *width;
    IBOutlet NSTextField *scanimagePath;
    IBOutlet NSTextField *helperPath;
	IBOutlet NSPanel *prefsPanel;
}

- (IBAction)savePrefs:(id)sender;
- (IBAction)helperBrowse:(id)sender;
+ (void)loadDefaults;

@end
