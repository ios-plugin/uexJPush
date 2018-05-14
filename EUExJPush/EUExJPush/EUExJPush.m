//
//  EUExJPush.m
//  EUExJPush
//
//  Created by liukangli on 15/5/18.
//  Copyright (c) 2015年 AppCan. All rights reserved.
//

#import "EUExJPush.h"

#import "JPUSHService.h"
#import "JPushInstance.h"
#import "EUtility.h"
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
    NSData *jsonData2 ;
    
    if ([[jsonData class] isSubclassOfClass:[NSDictionary class]])
    {
        jsonData2= [[jsonData JSONRepresentation] dataUsingEncoding:NSUTF8StringEncoding];
    }
    else
    {
        jsonData2= [jsonData dataUsingEncoding:NSUTF8StringEncoding];
    }
    
    
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

    [[JPushInstance sharedInstance] setLaunchOptions:launchOptions];


    

    
    
    
    
    
    
    return YES;
}


+ (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification{
    [[JPushInstance sharedInstance] callbackLocalNotification:notification state:application.applicationState];
}

BOOL isRootPageFinish = FALSE;
+ (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
//    NSLog(@"------deviceToken111:%@",[NSString stringWithFormat:@"%@",deviceToken]);
    
    if (isRootPageFinish == TRUE) {
         [JPUSHService registerDeviceToken:deviceToken];
    }
}

+(void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    
    [[JPushInstance sharedInstance] callbackRemoteNotification:userInfo state:application.applicationState];
    [JPUSHService handleRemoteNotification:userInfo];
//    NSLog(@"-----didReceiveRemoteNotification:%@",userInfo);
}

+(void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
   
    
//      NSLog(@"-----fetchCompletionHandler:%@",userInfo);
    // IOS 7 Support Required
    [[JPushInstance sharedInstance]callbackRemoteNotification:userInfo state:application.applicationState];
    [JPUSHService handleRemoteNotification:userInfo];
    completionHandler(UIBackgroundFetchResultNewData);
}

+(void)rootPageDidFinishLoading{

#if __IPHONE_OS_VERSION_MAX_ALLOWED > __IPHONE_7_1
        if ([[UIDevice currentDevice].systemVersion floatValue] >= 8.0) {
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
#else
        //categories 必须为nil
        [JPUSHService registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge |
                                                       UIRemoteNotificationTypeSound |
                                                       UIRemoteNotificationTypeAlert)
                                           categories:nil];
#endif
        
        //[JPUSHService setupWithOption:[JPushInstance sharedInstance].launchOptions];
    
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
    [JPUSHService setLogOFF];
    [[JPushInstance sharedInstance] wake];
//    NSLog(@"------setupWithOption:%@",data);
}








#pragma mark uexJPush APIs





/*
 ###init
 params:
 debug
 
 */



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
    
    [_JPush addLocalNotificationWithbroadCastTime:[NSDate dateWithTimeIntervalSinceNow:([broadCastTime doubleValue]/1000)]
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
