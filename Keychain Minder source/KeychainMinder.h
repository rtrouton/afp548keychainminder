/* KeychainMinder */

#import <Cocoa/Cocoa.h>

@interface KeychainMinder : NSObject
{
    IBOutlet NSTextField *newPass;
    IBOutlet NSTextField *oldPass;
	SecKeychainRef myDefaultKeychain;
	IBOutlet NSWindow *appWindow;
}
- (IBAction)change:(id)sender;
- (IBAction)ignore:(id)sender;
@end
