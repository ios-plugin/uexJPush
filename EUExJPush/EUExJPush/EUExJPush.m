//
//  EUExJPush.m
//  EUExJPush
//
//  Created by liukangli on 15/5/18.
//  Copyright (c) 2015年 AppCan. All rights reserved.
//

#import "EUExJPush.h"
#import "JPushInstance.h"

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
static BOOL isRootPageFinish = NO;
+(void)rootPageDidFinishLoading{
    [[JPushInstance sharedInstance] registerForRemoteNotification];
    isRootPageFinish = YES;
    if (!(ACLogGlobalLogMode & ACLogLevelDebug)) {
        [JPUSHService setLogOFF];
    }
    [[JPushInstance sharedInstance] wake];
   
}



+ (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    if (isRootPageFinish == TRUE) {
        [JPUSHService registerDeviceToken:deviceToken];
        
    }
}

+(void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    [[JPushInstance sharedInstance] callbackRemoteNotification:userInfo state:application.applicationState];
    [JPUSHService handleRemoteNotification:userInfo];
   
}

+ (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler: (void (^)(UIBackgroundFetchResult))completionHandler {
    [[JPushInstance sharedInstance] callbackRemoteNotification:userInfo state:application.applicationState];
    [JPUSHService handleRemoteNotification:userInfo];


    
    completionHandler(UIBackgroundFetchResultNewData);
}

+ (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification {
    [[JPushInstance sharedInstance] callbackLocalNotification:notification state:application.applicationState];

}



-(void)init:(NSMutableArray *)inArguments{

}







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
    [_JPush getConnectionStateWithCallbackFunction:func];
    
    
}



-(void)addLocalNotification:(NSMutableArray *)inArguments{
    

    ACArgsUnpack(NSDictionary *info) = inArguments;
    UEX_PARAM_GUARD_NOT_NIL(info);
    
    [_JPush addLocalNotificationWithTimeInterval: numberArg(info[@"broadCastTime"]).doubleValue/1000
                                   notificationId:stringArg(info[@"notificationId"]) ?: @"-1"
                                          content:stringArg(info[@"content"]) ?: @""
                                           extras:dictionaryArg(info[@"extras"])
                                            title:stringArg(info[@"title"]) ?: @""];

    
}




-(void)removeLocalNotification:(NSMutableArray *)inArguments{
    ACArgsUnpack(NSDictionary *info) = inArguments;
    NSString *notificationId = stringArg(info[@"notificationId"]);
    [_JPush removeLocalNotification:notificationId];
}



-(void)clearLocalNotifications:(NSMutableArray *)inArguments{
    [_JPush clearLocalNotifications];
    
    
}


-(void)setBadgeNumber:(NSMutableArray *)inArguments{
    ACArgsUnpack(NSNumber *number) = inArguments;
    [_JPush setBadgeNumber:number.integerValue];
}

-(void)disableLocalNotificationAlertView:(NSMutableArray *)inArguments{
    ACArgsUnpack(NSNumber *flag) = inArguments;
    UEX_PARAM_GUARD_NOT_NIL(flag);
    [JPushInstance sharedInstance].disableLocalNotificationAlertView = flag.boolValue;

    
}
@end
