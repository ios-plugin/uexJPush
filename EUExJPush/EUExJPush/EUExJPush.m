//
//  EUExJPush.m
//  EUExJPush
//
//  Created by liukangli on 15/5/18.
//  Copyright (c) 2015年 AppCan. All rights reserved.
//

#import "EUExJPush.h"
#import "JPushInstance.h"
#import "JSON.h"
#import "EUtility.h"
@interface EUExJPush()
@property (nonatomic,strong) JPushInstance *JPush;
@end
@implementation EUExJPush
- (id)initWithWebViewEngine:(id<AppCanWebViewEngineObject>)engine{
    if (self = [super initWithWebViewEngine:engine]) {
        
        if(self){
            _JPush=[JPushInstance sharedInstance];
            
        }
    }
    return self;
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
+(BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions{
    [[JPushInstance sharedInstance] setLaunchOptions:launchOptions];
    return YES;
}
BOOL isRootPageFinish = FALSE;
+(void)rootPageDidFinishLoading{
    [[JPushInstance sharedInstance] registerForRemoteNotification];
    isRootPageFinish = TRUE;
    //[JPUSHService setLogOFF];
    [[JPushInstance sharedInstance] wake];
   
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
    ACArgsUnpack(NSDictionary *info) = inArguments;
    ACJSFunctionRef *func = JSFunctionArg(inArguments.lastObject);
    NSString *alias=nil;
    if([info objectForKey:@"alias"]){
        alias=[info objectForKey:@"alias"];
    }
    NSArray *tags=nil;
    if([info objectForKey:@"tags"]){
        tags=[info objectForKey:@"tags"];
    }
    _JPush.configStatus=AliasAndTagsConfigStatusBoth;
    [_JPush setAlias:alias AndTags:[NSSet setWithArray:tags] Function:func];
    
    
}



/*
 ###setAlias
 
 */



-(void)setAlias:(NSMutableArray *)inArguments{
    
    if([inArguments count]<1) return;
    ACArgsUnpack(NSDictionary *info) = inArguments;
    ACJSFunctionRef *func = JSFunctionArg(inArguments.lastObject);
    NSString *alias=nil;
    if([info objectForKey:@"alias"]){
        alias=[info objectForKey:@"alias"];
    }
    _JPush.configStatus=AliasAndTagsConfigStatusOnlyAlias;
     [_JPush setAlias:alias AndTags:nil Function:func];
    
    
}



/*
 ###setTags
 
 */



-(void)setTags:(NSMutableArray *)inArguments{
    if([inArguments count]<1) return;
    ACArgsUnpack(NSDictionary *info) = inArguments;
    ACJSFunctionRef *func = JSFunctionArg(inArguments.lastObject);

    NSArray *tags=nil;
    if([info objectForKey:@"tags"]){
        tags=[info objectForKey:@"tags"];
    }
    _JPush.configStatus=AliasAndTagsConfigStatusOnlyTags;
     [_JPush setAlias:nil AndTags:[NSSet setWithArray:tags] Function:func];
    
    
    
}



/*
 ###getRegistrationID
 
 */



-(NSString*)getRegistrationID:(NSMutableArray *)inArguments{
    
    NSString *registrationID = [_JPush getRegistrationID];
    return registrationID;
    
}










/*
 ###getConnectionState
 
 */



-(void)getConnectionState:(NSMutableArray *)inArguments{
    
    ACJSFunctionRef *func = JSFunctionArg(inArguments.lastObject);
    [_JPush getConnectionStateWithfunction:func];
    
    
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
    ACArgsUnpack(NSDictionary *info) = inArguments;
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
    ACArgsUnpack(NSDictionary *info) = inArguments;
    NSString *notificationId=nil;
    if([info objectForKey:@"notificationId"]){
        notificationId=[NSString stringWithFormat:@"%@",[info objectForKey:@"notificationId"]];
        NSLog(@"removeLocalNotification:%@===%@",inArguments[0],notificationId);
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
