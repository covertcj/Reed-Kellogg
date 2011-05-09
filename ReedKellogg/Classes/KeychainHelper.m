#import "KeychainHelper.h"
#import <Security/Security.h>

@implementation KeychainHelper

+ (NSString *) getPasswordForUsername:(NSString *)username andService:(NSString *)service {
	if (username == nil || service == nil) {
		return nil;
	}
	
	// setup the keychain dictionary 
	NSArray * keys    = [[[NSArray alloc] initWithObjects: (NSString *) kSecClass,               kSecAttrAccount, kSecAttrService, nil] autorelease];
	NSArray * objects = [[[NSArray alloc] initWithObjects: (NSString *) kSecClassGenericPassword, username,       service,         nil] autorelease];
	NSMutableDictionary * query = [[[NSMutableDictionary alloc] initWithObjects: objects forKeys: keys] autorelease];
	
	// query the password data
	NSData * passwordData = nil;
	NSMutableDictionary * passwordQuery = [query mutableCopy];
	[passwordQuery setObject: (id) kCFBooleanTrue forKey: (id) kSecReturnData];
	SecItemCopyMatching((CFDictionaryRef) passwordQuery, (CFTypeRef *) &passwordData);
	
	[passwordData autorelease];
	[passwordQuery release];
	
	// extract the password if it exists
	if (passwordData) {
		return [[NSString alloc] initWithData: passwordData encoding: NSUTF8StringEncoding];
	}
	
	return nil;
}

+ (BOOL) storeUsername:(NSString *)username andPassword:(NSString *)password forService:(NSString *)service updateExisting:(BOOL)updateExisting {
	if (!username || !password || !service) {
		return NO;
	}
	
	OSStatus status = noErr;
	
	// check if there is an existing password
	NSString * existingPassword = [KeychainHelper getPasswordForUsername: username andService: service];
	if (existingPassword) 
	{
		// update the password if we are allowed to
		if (![existingPassword isEqualToString:password] && updateExisting) 
		{
			NSArray * keys  = [[[NSArray alloc] initWithObjects: (NSString *) kSecClass, kSecAttrService,  kSecAttrLabel, kSecAttrAccount, nil] autorelease];
			NSArray *objects = [[[NSArray alloc] initWithObjects: (NSString *) kSecClassGenericPassword, service, service, username, nil] autorelease];
			NSDictionary *query = [[[NSDictionary alloc] initWithObjects: objects forKeys: keys] autorelease];			
			
			status = SecItemUpdate((CFDictionaryRef) query, (CFDictionaryRef) [NSDictionary dictionaryWithObject: [password dataUsingEncoding: NSUTF8StringEncoding] forKey: (NSString *) kSecValueData]);
		}
	}
	else 
	{
		// create a new password entry
		NSArray *keys = [[[NSArray alloc] initWithObjects: (NSString *) kSecClass, kSecAttrService, kSecAttrLabel, kSecAttrAccount, kSecValueData, nil] autorelease];
		NSArray *objects = [[[NSArray alloc] initWithObjects: (NSString *) kSecClassGenericPassword, service, service, username, [password dataUsingEncoding: NSUTF8StringEncoding], nil] autorelease];
		NSDictionary *query = [[[NSDictionary alloc] initWithObjects: objects forKeys: keys] autorelease];			
		
		status = SecItemAdd((CFDictionaryRef) query, NULL);
	}
	
	if (status != noErr) 
	{
		return NO;
	}
	
	return YES;
}

@end