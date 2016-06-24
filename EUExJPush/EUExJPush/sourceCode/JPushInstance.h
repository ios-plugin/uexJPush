//
//  JPushInstance.h
//  EUExJPush
//
//  Created by AppCan on 15/5/18.
//  Copyright (c) 2015年 AppCan. All rights reserved.
//


#import "EUtility.h"
#import "JSON.h"
#import "EUExJPush.h"
@interface JPushInstance : NSObject


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
-(void)getConnectionStateWithfunction:(ACJSFunctionRef *)fuc;


- (void)addLocalNotificationWithbroadCastTime:(NSDate*)time
                              notificationId:(NSString*)ID
                                     content:(NSString *)content
                                      extras:(NSDictionary *)extras
                                       title:(NSString *)title;
- (void)removeLocalNotification:(NSString*)ID;
- (void)clearLocalNotifications;



- (void)callbackRemoteNotification:(NSDictionary*)userinfo state:(UIApplicationState)state;
- (void)callbackLocalNotification:(UILocalNotification*)notification state:(UIApplicationState)state;
- (void)callbackJSONWithName:(NSString *)name Object:(id)dict;
- (void) callbackJSONWithoutName:(NSString *)name Object:(id)obj;

- (void)setBadgeNumber:(NSInteger)bNum;


- (void)occurrenceCallback:(NSString*)errorMsg;//测试用回调
- (void)wake;

@end
