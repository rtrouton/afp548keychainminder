#import "KeychainMinder.h"

@implementation KeychainMinder

// the init method, we override it so that we can get some things tested
// before the GUI comes up

- (id)init
{
	[super init];
	
	//first we check for flag file to see if we run or not
	NSString *destination = [[[NSHomeDirectory()
        stringByAppendingPathComponent:@"Library"]
        stringByAppendingPathComponent:@"Preferences"]
        stringByAppendingPathComponent:@".KeychainMinder"];
	if ([[NSFileManager defaultManager] fileExistsAtPath:destination]) { 
		NSLog(@"Pref file says not to check.");
		[NSApp terminate: nil];
	}

	NSLog(@"Checking for locked login keychain");
	
	//we get the login keychain ref here, which will use in other places
	OSStatus getDefaultKeychain;
	getDefaultKeychain = SecKeychainCopyLogin ( &myDefaultKeychain);
	
	//now we check to see if it is locked or not
	OSStatus kcstatus ;
	UInt32 mystatus ;
	kcstatus = SecKeychainGetStatus ( myDefaultKeychain, &mystatus );
	
	//cast the UInt32 so we can test it
	int myIntStatus = mystatus ;

	// 2 means it's locked, otherwise we bail
	if (myIntStatus == 2 ){
		NSLog(@"Login keychain is locked.");
		[NSApp activateIgnoringOtherApps:YES];
	}
	else{
		NSLog(@"Keychain is unlocked already, so I'll go away now.");
		[NSApp terminate: nil];
	}
	return self;
}

- (IBAction)change:(id)sender
{
	OSStatus err;
	NSString *alertText;
	NSAlert *alert = [[[NSAlert alloc] init] autorelease];
	
	//get the passwords from the GUI
	const char * myOldPassword = [[oldPass stringValue] UTF8String];
	const char * myNewPassword = [[newPass stringValue] UTF8String];
	
	//get the password lengths, we need this for the change command
	UInt32 oldPasswordLength = strlen(myOldPassword);
	UInt32 newPasswordLength = strlen(myNewPassword);
	
	if (oldPasswordLength == 0) {
		alertText = @"Old password is blank.";
		NSLog(@"Old password is blank");
	}

	if (newPasswordLength == 0) {
		alertText = @"New password is blank.";
		NSLog(@"New password is blank");
	}
	
	if ( alertText == NULL ) {
	NSLog(@"changing password");
	err = SecKeychainChangePassword ( myDefaultKeychain, oldPasswordLength , myOldPassword , newPasswordLength , myNewPassword );
	NSLog(@"changed password");
	if ( err == noErr ) { 
		//if we're done we should go away
		[NSApp terminate: nil];
	}
	else {
		alertText = @"Password change was not successful. Vague and mysterious error code: xxx";//, errText ;
		NSLog(@"Change error");
	}
	}
	
	
//	if (alertText != NULL ) {

	[alert addButtonWithTitle:@"OK"];
	//[alert addButtonWithTitle:@"Cancel"];
	[alert setMessageText:@"Password Change Error"];
	[alert setInformativeText:alertText];
	[alert setAlertStyle:NSWarningAlertStyle];
	[alert beginSheetModalForWindow:appWindow modalDelegate:self didEndSelector:@selector(alertDidEnd:returnCode:contextInfo:) contextInfo:nil];
		
//	}

}

- (IBAction)ignore:(id)sender
{	
	//bail if the user doesn't care and hits the ignore button
	NSLog(@"User doesn't care about the password discrepency.");
	[NSApp terminate: nil];
}

- (void)alertDidEnd:(NSAlert *)alert returnCode:(int)returnCode contextInfo:(void *)contextInfo {
	
    if (returnCode == NSAlertFirstButtonReturn) {
		
		return;
		
    }
	
}
@end
