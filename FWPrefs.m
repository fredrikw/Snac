#import "FWPrefs.h"

@implementation FWPrefs

- (IBAction)savePrefs:(id)sender
{
	/* Save the defaults */
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	[defaults setObject:[[depth_option stringValue] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] forKey:@"depth_option"];
	[defaults setObject:[[depths stringValue] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] forKey:@"depths"];
	[defaults setObject:[[height stringValue] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] forKey:@"height"];
	[defaults setObject:[[max_x stringValue] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] forKey:@"max_x"];
	[defaults setObject:[[max_y stringValue] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] forKey:@"max_y"];
	[defaults setObject:[[mode_option stringValue] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] forKey:@"mode_option"];
	[defaults setObject:[[modes stringValue] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] forKey:@"modes"];
	[defaults setObject:[[res_option stringValue] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] forKey:@"res_option"];
	[defaults setObject:[[resolutions stringValue] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] forKey:@"resolutions"];
	[defaults setObject:[[top_left_x stringValue] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] forKey:@"top_left_x"];
	[defaults setObject:[[top_left_y stringValue] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] forKey:@"top_left_y"];
	[defaults setObject:[[width stringValue] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] forKey:@"width"];
	[defaults setObject:[[scanimagePath stringValue] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] forKey:@"scanimagePath"];
	[defaults setObject:[[helperPath stringValue] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] forKey:@"helperPath"];


	/* Close the prefs window */
	[prefsPanel performClose:nil];
	
	/* Tell the controller that defaults have changed */
	[[NSNotificationCenter defaultCenter] postNotificationName:@"FWPrefsChanged" object:self];

}

+ (void)loadDefaults
{
    NSString *userDefaultsValuesPath;
    NSDictionary *userDefaultsValuesDict;
    
    // load the default values for the user defaults
    userDefaultsValuesPath=[[NSBundle mainBundle] pathForResource:@"UserDefaults" 
														   ofType:@"plist"];
    userDefaultsValuesDict=[NSDictionary dictionaryWithContentsOfFile:userDefaultsValuesPath];
    
    // set them in the standard user defaults
    [[NSUserDefaults standardUserDefaults] registerDefaults:userDefaultsValuesDict];
}

- (void) awakeFromNib
{
	[FWPrefs loadDefaults];
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	[depth_option setStringValue:[defaults stringForKey:@"depth_option"]];
	[depths setStringValue:[defaults stringForKey:@"depths"]];
	[height setStringValue:[defaults stringForKey:@"height"]];
	[max_x setStringValue:[defaults stringForKey:@"max_x"]];
	[max_y setStringValue:[defaults stringForKey:@"max_y"]];
	[mode_option setStringValue:[defaults stringForKey:@"mode_option"]];
	[modes setStringValue:[defaults stringForKey:@"modes"]];
	[res_option setStringValue:[defaults stringForKey:@"res_option"]];
	[resolutions setStringValue:[defaults stringForKey:@"resolutions"]];
	[top_left_x setStringValue:[defaults stringForKey:@"top_left_x"]];
	[top_left_y setStringValue:[defaults stringForKey:@"top_left_y"]];
	[width setStringValue:[defaults stringForKey:@"width"]];
	[scanimagePath setStringValue:[defaults stringForKey:@"scanimagePath"]];
	[helperPath setStringValue:[defaults stringForKey:@"helperPath"]];
}	

- (void) windowWillClose:(NSNotification *)aNotification
{
	/* Synchronize TextFields with UserDefaults */
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	[depth_option setStringValue:[defaults stringForKey:@"depth_option"]];
	[depths setStringValue:[defaults stringForKey:@"depths"]];
	[height setStringValue:[defaults stringForKey:@"height"]];
	[max_x setStringValue:[defaults stringForKey:@"max_x"]];
	[max_y setStringValue:[defaults stringForKey:@"max_y"]];
	[mode_option setStringValue:[defaults stringForKey:@"mode_option"]];
	[modes setStringValue:[defaults stringForKey:@"modes"]];
	[res_option setStringValue:[defaults stringForKey:@"res_option"]];
	[resolutions setStringValue:[defaults stringForKey:@"resolutions"]];
	[top_left_x setStringValue:[defaults stringForKey:@"top_left_x"]];
	[top_left_y setStringValue:[defaults stringForKey:@"top_left_y"]];
	[width setStringValue:[defaults stringForKey:@"width"]];
	[scanimagePath setStringValue:[defaults stringForKey:@"scanimagePath"]];
	[helperPath setStringValue:[defaults stringForKey:@"helperPath"]];
}

- (IBAction) helperBrowse:(id)sender
{
	NSOpenPanel *op;
	int runResult;
	
	op = [NSOpenPanel openPanel];
	
	/* set up new attributes */
	
	/* display the NSSavePanel */
	runResult = [op runModalForDirectory:nil file:nil];
	
	/* if successful, save file under designated name */
	if (runResult == NSOKButton)
	{
		/* Set the  text-field to selection */
		[helperPath setStringValue:[[op filenames] objectAtIndex:0]];		
	}
}	

@end
