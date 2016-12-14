//
//  JPushInstance.h
//  EUExJPush
//
//  Created by AppCan on 15/5/18.
//  Copyright (c) 2015年 AppCan. All rights reserved.
//



@interface JPushInstance : NSObject<JPUSHRegisterDelegate>


typedef NS_ENUM(NSInteger,AliasAndTagsConfigStatus){
    AliasAndTagsConfigStatusNeither      = 0,
    AliasAndTagsConfigStatusOnlyAlias,
    AliasAndTagsConfigStatusOnlyTags,
    AliasAndTagsConfigStatusBoth
    
};




@property (nonatomic,assign) BOOL connectionState;
@property (nonatomic,assign) AliasAndTagsConfigStatus configStatus;
@property (nonatomic,strong) NSDictionary *launchOptions;
@property (nonatomic,assign) BOOL disableLocalNotificationAlertView;



+(instancetype)sharedInstance;
- (void)activateNotifications;
- (void)inactivateNotifications;


- (void)setAlias:(NSString *)alias AndTags:(NSSet *)tags Function:(ACJSFunctionRef*)fuc;



- (NSString*)getRegistrationID;
- (void)getConnectionStateWithCallbackFunction:(ACJSFunctionRef *)callback;
- (void)registerForRemoteNotification;

- (void)addLocalNotificationWithTimeInterval:(NSTimeInterval)timeInterval
                              notificationId:(NSString *)ID
                                     content:(NSString *)body
                                      extras:(NSDictionary *)extras
                                       title:(NSString *)title;
- (void)removeLocalNotification:(NSString *)ID;
- (void)clearLocalNotifications;



- (void)callbackRemoteNotification:(NSDictionary*)userinfo state:(UIApplicationState)state;
- (void)callbackLocalNotification:(UILocalNotification*)notification state:(UIApplicationState)state;
- (void)callbackJSONWithName:(NSString *)name Object:(id)dict;


- (void)setBadgeNumber:(NSInteger)badge;

- (void)wake;

@end
