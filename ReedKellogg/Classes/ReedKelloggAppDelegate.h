#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>


@interface ReedKelloggAppDelegate : NSObject <UIApplicationDelegate> {
	
	
    UIWindow *window;
    UINavigationController *navigationController;
	
	
	@private
	NSManagedObjectContext *managedObjectContext_;
    NSManagedObjectModel *managedObjectModel_;
    NSPersistentStoreCoordinator *persistentStoreCoordinator_;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UINavigationController *navigationController;


@property (nonatomic, retain, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, retain, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;



- (NSString *)applicationDocumentsDirectory;
- (void)saveContext;



@end
