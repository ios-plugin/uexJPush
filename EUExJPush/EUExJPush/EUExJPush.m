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
static NSDictionary *opt;
+(BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions{
    opt=launchOptions;


    
    NSDictionary *remoteNotification = [launchOptions objectForKey: UIApplicationLaunchOptionsRemoteNotificationKey];
    if(remoteNotification){
        [JPushInstance callBackRemoteNotification:remoteNotification];

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











#pragma mark uexJPush APIs





/*
 ###init
 params:
 debug
 
 */



-(void)init:(NSMutableArray *)inArguments{
    
    _JPush=[JPushInstance sharedInstance];
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
    
    [APService setupWithOption:opt];
    

    
}



/*
 ###stopPush
 
 */
#warning method stopPush was not finished


-(void)stopPush:(NSMutableArray *)inArguments{
    
    
    
    
}



/*
 ###resumePush
 
 */
#warning method resumePush was not finished


-(void)resumePush:(NSMutableArray *)inArguments{
    
    
    
    
}



/*
 ###isPushStopped
 
 */
#warning method isPushStopped was not finished


-(void)isPushStopped:(NSMutableArray *)inArguments{
    
    
    
    
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
 ###reportNotificationOpened
 
 */
#warning method reportNotificationOpened was not finished


-(void)reportNotificationOpened:(NSMutableArray *)inArguments{
    
    
    
    
}



/*
 ###clearAllNotifications
 
 */
#warning method clearAllNotifications was not finished


-(void)clearAllNotifications:(NSMutableArray *)inArguments{
    
    
    
    
}



/*
 ###clearNotificationById
 params:
 notificationId
 
 */
#warning method clearNotificationById was not finished


-(void)clearNotificationById:(NSMutableArray *)inArguments{
    
    if([inArguments count]<1) return;
    id info =[self getDataFromJson:inArguments[0]];
    NSString *notificationId=nil;
    if([info objectForKey:@"notificationId"]){
        notificationId=[info objectForKey:@"notificationId"];
    }
    
    
    
}



/*
 ###setPushTime
 params:
 weekDays
 startHour
 endHour
 
 */
#warning method setPushTime was not finished


-(void)setPushTime:(NSMutableArray *)inArguments{
    
    if([inArguments count]<1) return;
    id info =[self getDataFromJson:inArguments[0]];
    NSString *weekDays=nil;
    if([info objectForKey:@"weekDays"]){
        weekDays=[info objectForKey:@"weekDays"];
    }
    NSString *startHour=nil;
    if([info objectForKey:@"startHour"]){
        startHour=[info objectForKey:@"startHour"];
    }
    NSString *endHour=nil;
    if([info objectForKey:@"endHour"]){
        endHour=[info objectForKey:@"endHour"];
    }
    
    
    
}



/*
 ###setSilenceTime
 params:
 startHour
 startMinute
 endHour
 endMinute
 
 */
#warning method setSilenceTime was not finished


-(void)setSilenceTime:(NSMutableArray *)inArguments{
    
    if([inArguments count]<1) return;
    id info =[self getDataFromJson:inArguments[0]];
    NSString *startHour=nil;
    if([info objectForKey:@"startHour"]){
        startHour=[info objectForKey:@"startHour"];
    }
    NSString *startMinute=nil;
    if([info objectForKey:@"startMinute"]){
        startMinute=[info objectForKey:@"startMinute"];
    }
    NSString *endHour=nil;
    if([info objectForKey:@"endHour"]){
        endHour=[info objectForKey:@"endHour"];
    }
    NSString *endMinute=nil;
    if([info objectForKey:@"endMinute"]){
        endMinute=[info objectForKey:@"endMinute"];
    }
    
    
    
}



/*
 ###setLatestNotificationNumber
 params:
 maxNum
 
 */
#warning method setLatestNotificationNumber was not finished


-(void)setLatestNotificationNumber:(NSMutableArray *)inArguments{
    
    if([inArguments count]<1) return;
    id info =[self getDataFromJson:inArguments[0]];
    NSString *maxNum=nil;
    if([info objectForKey:@"maxNum"]){
        maxNum=[info objectForKey:@"maxNum"];
    }
    
    
    
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




/*
 ###cbIsPushStopped
 
 */
#warning cbIsPushStopped was not finished





/*
 ###onReceiveMessage
 
 */
#warning onReceiveMessage was not finished


/*
 ###onReceiveNotification
 
 */
#warning onReceiveNotification was not finished


/*
 ###onReceiveNotificationOpen
 
 */
#warning onReceiveNotificationOpen was not finished


/*
 ###onReceiveConnectionChange
 
 */
#warning onReceiveConnectionChange was not finished




@end
