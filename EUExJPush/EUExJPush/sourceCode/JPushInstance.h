//
//  JPushInstance.h
//  EUExJPush
//
//  Created by AppCan on 15/5/18.
//  Copyright (c) 2015年 AppCan. All rights reserved.
//


#import "EUtility.h"
#import "JSON.h"
@interface JPushInstance : NSObject


typedef NS_ENUM(NSInteger,AliasAndTagsConfigStatus){
    Neither      = 0,
    OnlyAlias,
    OnlyTags,
    Both
    
};



@property (nonatomic,assign) BOOL connectionState;
@property (nonatomic,assign) AliasAndTagsConfigStatus configStatus;
@property(nonatomic,strong)NSDictionary *pushLaunchDict;



+(instancetype)sharedInstance;
-(void)activateNotifications;
-(void)inactivateNotifications;


-(void)setAlias:(NSString *)alias AndTags:(NSSet *)tags;



-(void)getRegistrationID;
-(void)getConnectionState;


-(void)addLocalNotificationWithbroadCastTime:(NSDate*)time
                              notificationId:(NSString*)ID
                                     content:(NSString *)content
                                      extras:(NSDictionary *)extras;
-(void)removeLocalNotification:(NSString*)ID;
-(void)clearLocalNotifications;



+(void)callBackRemoteNotification:(NSDictionary*)userinfo;
+(void)callBackLocalNotification:(UILocalNotification*)notification;
- (void) callBackJsonWithName:(NSString *)name Object:(id)dict;

-(void)occurrenceCallBack:(NSString*)errorMsg;//测试用回调
-(void)onLaunchedByPush:(NSDictionary*)dict;
-(void)push;

@end
