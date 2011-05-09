#import <UIKit/UIKit.h>

@interface KeychainHelper : NSObject {
	
}

+ (NSString *) getPasswordForUsername:(NSString *)username andService:(NSString *)service;
+ (BOOL) storeUsername:(NSString *)username andPassword:(NSString *)password forService:(NSString *)service updateExisting:(BOOL)updateExisting;

@end