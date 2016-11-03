//
//  EUExJPush.m
//  EUExJPush
//
//  Created by liukangli on 15/5/18.
//  Copyright (c) 2015年 AppCan. All rights reserved.
//

#import "EUExJPush.h"
#import "JPushInstance.h"
#import "EUtility.h"
@interface EUExJPush()<JPUSHRegisterDelegate>
@property (nonatomic,strong) JPushInstance *JPush;
@end
@implementation EUExJPush
- (id)initWithBrwView:(EBrowserView *)eInBrwView{
    self = [super initWithBrwView:eInBrwView];

    if(self){
        _JPush=[JPushInstance sharedInstance];

    }
    return  self;
}
- (id)getDataFromJson:(NSString *)jsonData{
    NSError *error = nil;



    NSData *jsonData2= [jsonData dataUsingEncoding:NSUTF8StringEncoding];

    id jsonObject = [NSJSONSerialization JSONObjectWithData:jsonData2

                                                    options:NSJSONReadingMutableContainers

                                                      error:&error];

    if (jsonObject != nil && error == nil){

        return jsonObject;
    }else{

        // 解析錯誤

        return nil;
    }

}
BOOL isRootPageFinish = FALSE;
+(void)rootPageDidFinishLoading{
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 10.0) {
#ifdef NSFoundationVersionNumber_iOS_9_x_Max
        JPUSHRegisterEntity * entity = [[JPUSHRegisterEntity alloc] init];
        entity.types = UNAuthorizationOptionAlert|UNAuthorizationOptionBadge|UNAuthorizationOptionSound;
        [JPUSHService registerForRemoteNotificationConfig:entity delegate:self];
#endif
    } else if ([[UIDevice currentDevice].systemVersion floatValue] >= 8.0) {
        //可以添加自定义categories
        [JPUSHService registerForRemoteNotificationTypes:(UIUserNotificationTypeBadge |
                                                          UIUserNotificationTypeSound |
                                                          UIUserNotificationTypeAlert)
                                              categories:nil];
    } else {
        //categories 必须为nil
        [JPUSHService registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge |
                                                          UIRemoteNotificationTypeSound |
                                                          UIRemoteNotificationTypeAlert)
                                              categories:nil];
    }
    
    //2.1.9版本新增获取registration id block接口。
    [JPUSHService registrationIDCompletionHandler:^(int resCode, NSString *registrationID) {
        if(resCode == 0){
            NSLog(@"registrationID获取成功：%@",registrationID);
        }
        else{
            NSLog(@"registrationID获取失败，code：%d",resCode);
        }
    }];

    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"PushConfig" ofType:@"plist"];
    NSDictionary *data = [NSDictionary dictionaryWithContentsOfFile:path];
    
    NSString *appKey=[data objectForKey:@"APP_KEY"];
    NSString *channel=[data objectForKey:@"CHANNEL"];
    NSString *apsForProduction=[data objectForKey:@"APS_FOR_PRODUCTION"];
        if([apsForProduction isEqual:@"0"]){
            [JPUSHService setupWithOption:[JPushInstance sharedInstance].launchOptions appKey:appKey channel:channel apsForProduction:NO];
        }
        else{
            [JPUSHService setupWithOption:[JPushInstance sharedInstance].launchOptions appKey:appKey channel:channel apsForProduction:YES];
        }
    isRootPageFinish = TRUE;
    [JPUSHService setDebugMode];
    [[JPushInstance sharedInstance] wake];
   
}

+(BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions{
     [[JPushInstance sharedInstance] setLaunchOptions:launchOptions];
    return YES;
}

+ (void)application:(UIApplication *)application
didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    NSLog(@"%@", [NSString stringWithFormat:@"Device Token: %@", deviceToken]);
    if (isRootPageFinish == TRUE) {
        [JPUSHService registerDeviceToken:deviceToken];
        
    }
}

+(void)application:(UIApplication *)application
didReceiveRemoteNotification:(NSDictionary *)userInfo {
    [[JPushInstance sharedInstance] callbackRemoteNotification:userInfo state:application.applicationState];
    [JPUSHService handleRemoteNotification:userInfo];
    NSLog(@"iOS6及以下系统，收到通知:%@",userInfo);
   
}

+ (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler: (void (^)(UIBackgroundFetchResult))completionHandler {
      [[JPushInstance sharedInstance] callbackRemoteNotification:userInfo state:application.applicationState];
    [JPUSHService handleRemoteNotification:userInfo];
    NSLog(@"iOS7及以上系统，收到通知:%@", userInfo);
    
    if ([[UIDevice currentDevice].systemVersion floatValue]<10.0 || application.applicationState>0) {
       
    }
    
    completionHandler(UIBackgroundFetchResultNewData);
}

+ (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification {
    [[JPushInstance sharedInstance] callbackLocalNotification:notification state:application.applicationState];

}

#ifdef NSFoundationVersionNumber_iOS_9_x_Max
#pragma mark- JPUSHRegisterDelegate
//App处于前台接收通知时
- (void)jpushNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(NSInteger))completionHandler {
    NSDictionary * userInfo = notification.request.content.userInfo;
    
    UNNotificationRequest *request = notification.request; // 收到推送的请求
    UNNotificationContent *content = request.content; // 收到推送的消息内容
    
    NSNumber *badge = content.badge;  // 推送消息的角标
    NSString *body = content.body;    // 推送消息体
    UNNotificationSound *sound = content.sound;  // 推送消息的声音
    NSString *subtitle = content.subtitle;  // 推送消息的副标题
    NSString *title = content.title;  // 推送消息的标题
    
    if([notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
        [[JPushInstance sharedInstance] callbackRemoteNotification:userInfo state:UIApplicationStateActive];
        [JPUSHService handleRemoteNotification:userInfo];
        NSLog(@"iOS10 前台收到远程通知:%@", userInfo);
        
       
        
    }
    else {
        // 判断为本地通知
         [[JPushInstance sharedInstance] callbackLocalNotificationiOS10:content state:UIApplicationStateActive];
        NSLog(@"iOS10 前台收到本地通知:{\nbody:%@，\ntitle:%@,\nsubtitle:%@,\nbadge：%@，\nsound：%@，\nuserInfo：%@\n}",body,title,subtitle,badge,sound,userInfo);
    }
    completionHandler(UNNotificationPresentationOptionBadge|UNNotificationPresentationOptionSound|UNNotificationPresentationOptionAlert); // 需要执行这个方法，选择是否提醒用户，有Badge、Sound、Alert三种类型可以设置
}
////App通知的点击事件
- (void)jpushNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)())completionHandler {
    
    NSDictionary * userInfo = response.notification.request.content.userInfo;
    UNNotificationRequest *request = response.notification.request; // 收到推送的请求
    UNNotificationContent *content = request.content; // 收到推送的消息内容
    
    NSNumber *badge = content.badge;  // 推送消息的角标
    NSString *body = content.body;    // 推送消息体
    UNNotificationSound *sound = content.sound;  // 推送消息的声音
    NSString *subtitle = content.subtitle;  // 推送消息的副标题
    NSString *title = content.title;  // 推送消息的标题
    
    if([response.notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
         [[JPushInstance sharedInstance] callbackRemoteNotification:userInfo state:UIApplicationStateInactive];
        [JPUSHService handleRemoteNotification:userInfo];
        NSLog(@"iOS10 收到远程通知:%@", userInfo);
       
        
    }
    else {
        // 判断为本地通知
         [[JPushInstance sharedInstance] callbackLocalNotificationiOS10:content state:UIApplicationStateInactive];
        NSLog(@"iOS10 收到本地通知:{\nbody:%@，\ntitle:%@,\nsubtitle:%@,\nbadge：%@，\nsound：%@，\nuserInfo：%@\n}",body,title,subtitle,badge,sound,userInfo);
    }
    
    completionHandler();  // 系统要求执行这个方法
}
#endif


-(void)init:(NSMutableArray *)inArguments{

}






/*
 ###setAliasAndTags
 params:
 alias
 tags
 
 */



-(void)setAliasAndTags:(NSMutableArray *)inArguments{
    if([inArguments count]<1) return;
    id info =[self getDataFromJson:inArguments[0]];
    NSString *alias=nil;
    if([info objectForKey:@"alias"]){
        alias=[info objectForKey:@"alias"];
    }
    NSArray *tags=nil;
    if([info objectForKey:@"tags"]){
        tags=[info objectForKey:@"tags"];
    }
    _JPush.configStatus=AliasAndTagsConfigStatusBoth;
    [_JPush setAlias:alias AndTags:[NSSet setWithArray:tags]];
    
    
}



/*
 ###setAlias
 
 */



-(void)setAlias:(NSMutableArray *)inArguments{
    
    if([inArguments count]<1) return;
    id info =[self getDataFromJson:inArguments[0]];
    NSString *alias=nil;
    if([info objectForKey:@"alias"]){
        alias=[info objectForKey:@"alias"];
    }
    _JPush.configStatus=AliasAndTagsConfigStatusOnlyAlias;
    [_JPush setAlias:alias AndTags:nil];
    
    
}



/*
 ###setTags
 
 */



-(void)setTags:(NSMutableArray *)inArguments{
    if([inArguments count]<1) return;
    id info =[self getDataFromJson:inArguments[0]];

    NSArray *tags=nil;
    if([info objectForKey:@"tags"]){
        tags=[info objectForKey:@"tags"];
    }
    _JPush.configStatus=AliasAndTagsConfigStatusOnlyTags;
    [_JPush setAlias:nil AndTags:[NSSet setWithArray:tags]];
    
    
    
}



/*
 ###getRegistrationID
 
 */



-(void)getRegistrationID:(NSMutableArray *)inArguments{
    
    [_JPush getRegistrationID];
    
    
}










/*
 ###getConnectionState
 
 */



-(void)getConnectionState:(NSMutableArray *)inArguments{
    
    [_JPush getConnectionState];
    
    
}



/*
 ###addLocalNotification
 params:
 builderId
 title
 content
 extras
 notificationId
 broadCastTime
 
 */



-(void)addLocalNotification:(NSMutableArray *)inArguments{
    
    if([inArguments count]<1) return;
    id info =[self getDataFromJson:inArguments[0]];
    if(![info isKindOfClass:[NSDictionary class]]||![info objectForKey:@"broadCastTime"]){
        return;
    }
    NSDictionary *extras=nil;
    if([info objectForKey:@"extras"]){
        extras=[info objectForKey:@"extras"];
    }
    id nid=[info objectForKey:@"notificationId"];
    if([nid isKindOfClass:[NSNumber class]]){
        nid=[nid stringValue];
    }
    NSString *broadCastTime=[info objectForKey:@"broadCastTime"]?:@"0";
    
    [_JPush addLocalNotificationWithbroadCastTime:[NSDate dateWithTimeIntervalSinceNow:([broadCastTime doubleValue]/1000)] timeInterval:([broadCastTime doubleValue]/1000)
                                   notificationId:nid?:@"-1"
                                          content:[info objectForKey:@"content"]?:@""
                                           extras:[info objectForKey:@"extras"]?:nil
                                            title:[info objectForKey:@"title"]?:@""];
    
}



/*
 ###removeLocalNotification
 params:
 notificationId
 
 */



-(void)removeLocalNotification:(NSMutableArray *)inArguments{
    
    if([inArguments count]<1) return;
    id info =[self getDataFromJson:inArguments[0]];
    NSString *notificationId=nil;
    if([info objectForKey:@"notificationId"]){
        notificationId=[NSString stringWithFormat:@"%ld",(long)[info objectForKey:@"notificationId"]];
    }
    [_JPush removeLocalNotification:notificationId];
    
    
}



/*
 ###clearLocalNotifications
 
 */



-(void)clearLocalNotifications:(NSMutableArray *)inArguments{
    
    [_JPush clearLocalNotifications];
    
    
}


-(void)setBadgeNumber:(NSMutableArray *)inArguments{
    NSInteger num=0;
    if([inArguments count]>0){
        num=[inArguments[0] integerValue];
    }
    [_JPush setBadgeNumber:num];
}

-(void)disableLocalNotificationAlertView:(NSMutableArray *)inArguments{
    if([inArguments count]==0){
        return;
    }
    if([inArguments[0] integerValue]==1){
        [JPushInstance sharedInstance].disableLocalNotificationAlertView=YES;
    }else{
        [JPushInstance sharedInstance].disableLocalNotificationAlertView=NO;
    }
}
@end
