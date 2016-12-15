//
//  JPushInstance.h
//  EUExJPush
//
//  Created by AppCan on 15/5/18.
//  Copyright (c) 2015年 AppCan. All rights reserved.
//



@interface JPushInstance : NSObject<JPUSHRegisterDelegate>





@property (nonatomic,assign) BOOL connectionState;
@property (nonatomic,assign) BOOL showNotificationAlertInForeground;



+ (instancetype)sharedInstance;

- (void)notifyApplication:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions;
- (void)notifyRootPageDidFinishLoading;
- (void)notifyApplication:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken;
- (void)notifyApplication:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo;
- (void)notifyApplication:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler: (void (^)(UIBackgroundFetchResult))completionHandler;
- (void)notifyApplication:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification;

- (void)addLocalNotificationWithTimeInterval:(NSTimeInterval)timeInterval
                              notificationId:(NSString *)ID
                                     content:(NSString *)body
                                      extras:(NSDictionary *)extras
                                       title:(NSString *)title;
- (void)removeLocalNotificationWithID:(NSString *)ID;
- (void)removeAllLocalNotifications;





- (void)setBadgeNumber:(NSInteger)badge;


@end
