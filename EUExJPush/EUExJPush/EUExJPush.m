//
//  EUExJPush.m
//  EUExJPush
//
//  Created by liukangli on 15/5/18.
//  Copyright (c) 2015年 AppCan. All rights reserved.
//

#import "EUExJPush.h"

#import "APService.h"
#import "JPushInstance.h"
@interface EUExJPush()
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

-(void)clean{


}

-(void)dealloc{
    [self clean];
    [super dealloc];
}

//从json字符串中获取数据
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
#pragma mark applicationDelegate

+(BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions{
#if __IPHONE_OS_VERSION_MAX_ALLOWED > __IPHONE_7_1
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 8.0) {
        //可以添加自定义categories
        [APService registerForRemoteNotificationTypes:(UIUserNotificationTypeBadge |
                                                       UIUserNotificationTypeSound |
                                                       UIUserNotificationTypeAlert)
                                           categories:nil];
    } else {
        //categories 必须为nil
        [APService registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge |
                                                       UIRemoteNotificationTypeSound |
                                                       UIRemoteNotificationTypeAlert)
                                           categories:nil];
    }
#else
    //categories 必须为nil
    [APService registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge |
                                                   UIRemoteNotificationTypeSound |
                                                   UIRemoteNotificationTypeAlert)
                                       categories:nil];
#endif

    [APService setupWithOption:launchOptions];
   


    
    NSDictionary *remoteNotification = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
    if(remoteNotification){
        NSLog(@"onload2");
        [[JPushInstance sharedInstance] onLaunchedByPush:remoteNotification];
        //[JPushInstance callBackRemoteNotification:remoteNotification];

    }
    
    
    
    
    
    
    return YES;
}


+ (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification{
    [JPushInstance callBackLocalNotification:notification];
}
+ (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    
    [APService registerDeviceToken:deviceToken];
    
    
    
}

+(void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    
    [JPushInstance callBackRemoteNotification:userInfo];
    [APService handleRemoteNotification:userInfo];
}

+(void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    
    
    // IOS 7 Support Required
    [JPushInstance callBackRemoteNotification:userInfo];
    [APService handleRemoteNotification:userInfo];
    completionHandler(UIBackgroundFetchResultNewData);
}

+ (void)applicationDidBecomeActive:(UIApplication *)application{
    [[JPushInstance sharedInstance] push];
}









#pragma mark uexJPush APIs





/*
 ###init
 params:
 debug
 
 */



-(void)init:(NSMutableArray *)inArguments{
 /*
  
#if __IPHONE_OS_VERSION_MAX_ALLOWED > __IPHONE_7_1
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 8.0) {
        //可以添加自定义categories
        [APService registerForRemoteNotificationTypes:(UIUserNotificationTypeBadge |
                                                       UIUserNotificationTypeSound |
                                                       UIUserNotificationTypeAlert)
                                           categories:nil];
    } else {
        //categories 必须为nil
        [APService registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge |
                                                       UIRemoteNotificationTypeSound |
                                                       UIRemoteNotificationTypeAlert)
                                           categories:nil];
    }
#else
    //categories 必须为nil
    [APService registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge |
                                                   UIRemoteNotificationTypeSound |
                                                   UIRemoteNotificationTypeAlert)
                                       categories:nil];
#endif
    
    //[APService setupWithOption:opt];
    [_JPush push];

    */
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
    _JPush.configStatus=Both;
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
    _JPush.configStatus=OnlyAlias;
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
    _JPush.configStatus=OnlyTags;
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

    NSString *content=nil;
    if([info objectForKey:@"content"]){
        content=[info objectForKey:@"content"];
    }
    NSDictionary *extras=nil;
    if([info objectForKey:@"extras"]){
        extras=[info objectForKey:@"extras"];
    }
    NSString *notificationId=nil;
    if([info objectForKey:@"notificationId"]){
        notificationId=[NSString stringWithFormat:@"%ld",(long)[info objectForKey:@"notificationId"]];
    }
    NSString *broadCastTime=nil;
    if([info objectForKey:@"broadCastTime"]){
        broadCastTime=[info objectForKey:@"broadCastTime"];
    }
    
    [_JPush addLocalNotificationWithbroadCastTime:[NSDate dateWithTimeIntervalSinceNow:([broadCastTime doubleValue]/1000)]
                                   notificationId:notificationId
                                          content:content
                                           extras:extras];
    
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






@end
