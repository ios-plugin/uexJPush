//
//  JPushInstance.m
//  EUExJPush
//
//  Created by AppCan on 15/5/18.
//  Copyright (c) 2015年 AppCan. All rights reserved.
//

#import "JPushInstance.h"
#import "JPUSHService.h"


NSString *const uexJPushOnReceiveNotificationCallbackKey=@"onReceiveNotification";
NSString *const uexJPushOnReceiveNotificationOpenCallbackKey=@"onReceiveNotificationOpen";

@interface JPushInstance ()
@property (nonatomic,strong) ACJSFunctionRef *functBoth;
@property (nonatomic,strong) ACJSFunctionRef *functTags;
@property (nonatomic,strong) ACJSFunctionRef *functAlias;

@end
@implementation JPushInstance





-(void)wake{
    if([self.launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey]){
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(500 * NSEC_PER_MSEC)), dispatch_get_main_queue(), ^{
            [self callbackRemoteNotification:[self.launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey] state:UIApplicationStateInactive];
        });
    }
    if([self.launchOptions objectForKey:UIApplicationLaunchOptionsLocalNotificationKey]){
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(500 * NSEC_PER_MSEC)), dispatch_get_main_queue(), ^{
            [self callbackLocalNotification:[self.launchOptions objectForKey:UIApplicationLaunchOptionsLocalNotificationKey] state:UIApplicationStateInactive];
        });
    }
    
    
}

#pragma mark sharedInstance
+ (instancetype) sharedInstance
{
    static JPushInstance *sharedObj= nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedObj=[[self alloc]init];
    });
    return sharedObj;
}



- (instancetype)init
{
    
    if (self = [super init]){
        self.connectionState =NO;
        self.configStatus=AliasAndTagsConfigStatusNeither;
        [self activateNotifications];
        self.disableLocalNotificationAlertView=NO;

        
    }
    
    return self;

}


#pragma mark Notifications



-(void)activateNotifications{
//    NSLog(@"------activateNotifications");
    NSNotificationCenter *defaultCenter = [NSNotificationCenter defaultCenter];
    [defaultCenter addObserver:self
                      selector:@selector(networkDidSetup:)
                          name:kJPFNetworkDidSetupNotification
                        object:nil];
    [defaultCenter addObserver:self
                      selector:@selector(networkDidClose:)
                          name:kJPFNetworkDidCloseNotification
                        object:nil];
    [defaultCenter addObserver:self
                      selector:@selector(networkDidRegister:)
                          name:kJPFNetworkDidRegisterNotification
                        object:nil];
    [defaultCenter addObserver:self
                      selector:@selector(networkDidLogin:)
                          name:kJPFNetworkDidLoginNotification
                        object:nil];
    [defaultCenter addObserver:self
                      selector:@selector(networkDidReceiveMessage:)
                          name:kJPFNetworkDidReceiveMessageNotification
                        object:nil];
    [defaultCenter addObserver:self
                      selector:@selector(serviceError:)
                          name:kJPFServiceErrorNotification
                        object:nil];
}
-(void)inactivateNotifications{
    NSNotificationCenter *defaultCenter = [NSNotificationCenter defaultCenter];
    [defaultCenter removeObserver:self
                             name:kJPFNetworkDidSetupNotification
                           object:nil];
    [defaultCenter removeObserver:self
                             name:kJPFNetworkDidCloseNotification
                           object:nil];
    [defaultCenter removeObserver:self
                             name:kJPFNetworkDidRegisterNotification
                           object:nil];
    [defaultCenter removeObserver:self
                             name:kJPFNetworkDidLoginNotification
                           object:nil];
    [defaultCenter removeObserver:self
                             name:kJPFNetworkDidReceiveMessageNotification
                           object:nil];
    [defaultCenter removeObserver:self
                             name:kJPFServiceErrorNotification
                           object:nil];
}

//收到APNs推送
-(void)callbackRemoteNotification:(NSDictionary*)userinfo state:(UIApplicationState)state{
    switch (state) {
        case UIApplicationStateActive: {
            [self callbackJSONWithName:uexJPushOnReceiveNotificationCallbackKey Object:[self parseRemoteNotification:userinfo]] ;
            break;
        }
        case UIApplicationStateInactive: {
            [self callbackJSONWithName:uexJPushOnReceiveNotificationOpenCallbackKey Object:[self parseRemoteNotification:userinfo]] ;
            break;
        }
        case UIApplicationStateBackground: {
            
            //[self callbackJSONWithName:@"onReceiveNotificationBackground" Object:[self parseRemoteNotification:userinfo]] ;
            break;
        }
    }
    
}




-(NSDictionary *)parseRemoteNotification:(NSDictionary*)userinfo{
    NSMutableDictionary *dict=[NSMutableDictionary dictionary];
    NSMutableDictionary *extras=[NSMutableDictionary dictionary];
    NSArray *keys=[userinfo allKeys];
    
    for(int i=0;i<[keys count];i++){
        NSString *keyStr=keys[i];
        if((![keyStr isEqual:@"aps"]) && (![keyStr isEqual:@"_j_msgid"])){
            [extras setValue:[userinfo objectForKey:keyStr] forKey:keyStr];
        }
    }
    NSDictionary *aps=[userinfo objectForKey:@"aps"];
    [dict setValue:[aps objectForKey:@"alert"] forKey:@"content"];
    [dict setValue:@(YES) forKey:@"isAPNs"];
    [dict setValue:extras forKey:@"extras"];
    return dict;

}


//收到自定义消息
-(void)networkDidReceiveMessage:(NSNotification *)notification{
    NSDictionary * userInfo = [notification userInfo];
    NSMutableDictionary *dict=[NSMutableDictionary dictionary];
    NSString *content = [userInfo valueForKey:@"content"];
    [dict setValue:content forKey:@"message"];
    NSDictionary *extras = [userInfo valueForKey:@"extras"];
    [dict setValue:extras forKey:@"extras"];
//    NSLog(@"-----onReceiveMessage:%@",dict);
    [self callbackJSONWithName:@"onReceiveMessage" Object:dict];
   
}

-(void)networkDidSetup:(NSNotification *)notification{
    self.connectionState=YES;
    NSMutableDictionary *dict=[NSMutableDictionary dictionary];
    [dict setValue:@"0" forKey:@"connect"];
//    NSLog(@"-----onReceiveConnectionChange:%@",dict);
    [self callbackJSONWithName:@"onReceiveConnectionChange" Object:dict];
}

-(void)networkDidClose:(NSNotification *)notification{
    self.connectionState=NO;
    NSMutableDictionary *dict=[NSMutableDictionary dictionary];
    [dict setValue:@"1" forKey:@"connect"];
    
//    NSLog(@"-----onReceiveConnectionChange:%@",dict);

    [self callbackJSONWithName:@"onReceiveConnectionChange" Object:dict];
}

-(void)networkDidRegister:(NSNotification *)notification{
//    NSLog(@"-----networkDidRegister:%@",notification.userInfo);
   
}
-(void)networkDidLogin:(NSNotification *)notification{
    NSMutableDictionary *registrationDict=[NSMutableDictionary dictionary];
    [registrationDict setValue:[JPUSHService registrationID] forKey:@"title"];
//    NSLog(@"-----onReceiveRegistration:%@",registrationDict);
    [self callbackJSONWithName:@"onReceiveRegistration" Object:registrationDict];
    
}
-(void)serviceError:(NSNotification *)notification{
//    NSLog(@"-----serviceError:%@",notification.userInfo);
    [self occurrenceCallback:[NSString stringWithFormat:@"Service Error : %@",notification.userInfo]];
}






#pragma mark - alias and tags
- (void)tagsAliasCallback:(int)iResCode
                     tags:(NSSet *)tags
                    alias:(NSString *)alias{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    NSMutableDictionary *resultDict = [NSMutableDictionary dictionary];
    [dict setValue:[NSString stringWithFormat:@"%i",iResCode] forKey:@"result"];
    NSNumber *error = @(iResCode);;
    switch (self.configStatus) {
        case AliasAndTagsConfigStatusBoth:
            [dict setValue:alias forKey:@"alias"];
            [dict setValue:[tags allObjects] forKey:@"tags"];
            [self callbackJSONWithName:@"cbSetAliasAndTags" Object:dict];
        
            [resultDict setValue:alias forKey:@"alias"];
            [resultDict setValue:[tags allObjects] forKey:@"tags"];
            [self.functBoth executeWithArguments:ACArgsPack(error,resultDict)];
        
            break;
        case AliasAndTagsConfigStatusOnlyAlias :
            [dict setValue:alias forKey:@"alias"];
            [self callbackJSONWithName:@"cbSetAlias" Object:dict];
        
            [resultDict setValue:alias forKey:@"alias"];
            [self.functAlias executeWithArguments:ACArgsPack(error,resultDict)];
            break;
        case AliasAndTagsConfigStatusOnlyTags:
            [dict setValue:[tags allObjects] forKey:@"tags"];
            [self callbackJSONWithName:@"cbSetTags" Object:dict];
        
           [resultDict setValue:[tags allObjects] forKey:@"tags"];
           [self.functTags executeWithArguments:ACArgsPack(error,resultDict)];
            break;
            
            
        case AliasAndTagsConfigStatusNeither: {
            break;
        }

    }
    
    self.configStatus=AliasAndTagsConfigStatusNeither;
}


-(void)setAlias:(NSString *)alias AndTags:(NSSet*)tags Function:(ACJSFunctionRef *)fuc{
    if (alias && tags == nil) {
        self.functAlias = fuc;
    }
    if (tags && alias == nil) {
        self.functTags = fuc;
    }
    if (tags && alias) {
        self.functBoth = fuc;
    }
    [JPUSHService setTags:[JPUSHService filterValidTags:tags]
                 alias:alias
      callbackSelector:@selector(tagsAliasCallback:tags:alias:)
                object:self];
}





-(NSString*)getRegistrationID{
   // NSMutableDictionary *dict=[NSMutableDictionary dictionary];
    //[dict setValue:[JPUSHService registrationID] forKey:@"registrationID"];
    //[self callbackJSONWithName:@"cbGetRegistrationID" Object:dict];
    
    return [JPUSHService registrationID];

}
-(void)getConnectionStateWithfunction:(ACJSFunctionRef *)fuc{
    NSString *state=@"";
    if(self.connectionState){
        state=@"0";
    }else{
        state=@"1";
    }
    NSNumber *error = @(state.intValue);
    NSMutableDictionary *dict =[NSMutableDictionary dictionary];
    [dict setValue:state forKey:@"result"];
    [self callbackJSONWithName:@"cbGetConnectionState" Object:dict];
    [fuc executeWithArguments:ACArgsPack(error)];
}
#pragma mark LocalNotifications

-(void)callbackLocalNotification:(UILocalNotification*)notification state:(UIApplicationState)state{
    
    if(!self.disableLocalNotificationAlertView){
           [JPUSHService showLocalNotificationAtFront:notification identifierKey:nil];
    }
    switch (state) {
        case UIApplicationStateActive: {
            [self callbackJSONWithName:uexJPushOnReceiveNotificationCallbackKey Object:[self parseLocalNotification:notification]];
            break;
        }
        case UIApplicationStateInactive: {
            [self callbackJSONWithName:uexJPushOnReceiveNotificationOpenCallbackKey Object:[self parseLocalNotification:notification]];
            break;
        }
        case UIApplicationStateBackground: {

            break;
        }

    }
    

}

-(NSDictionary *)parseLocalNotification:(UILocalNotification*)notification{
    __block NSMutableDictionary *dict=[NSMutableDictionary dictionary];
    __block NSMutableDictionary *extras=[NSMutableDictionary dictionary];
    NSDictionary *info = notification.userInfo;
    [info enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        if([key isEqual:@"__JPFNotificationKey"]){
            [dict setValue:@([obj integerValue]) forKey:@"notificationId"];
        }else{
            [extras setValue:obj forKey:key];
        }
    }];
    [dict setValue:extras forKey:@"extras"];
    [dict setValue:notification.alertBody forKey:@"content"];
    [dict setValue:@(NO) forKey:@"isAPNs"];
    return dict;
}


-(void)addLocalNotificationWithbroadCastTime:(NSDate*)time
                              notificationId:(NSString*)ID
                                     content:(NSString *)content
                                      extras:(NSDictionary *)extras
                                       title:(NSString *)title{


    [JPUSHService setLocalNotification:time
                          alertBody:content
                              badge:-1
                        alertAction:nil
                      identifierKey:ID
                           userInfo:extras
                          soundName:nil];
}



-(void)removeLocalNotification:(NSString*)ID{
    [JPUSHService deleteLocalNotificationWithIdentifierKey:ID];
}

-(void)clearLocalNotifications{

    [JPUSHService clearAllLocalNotifications];
}

#pragma mark badge number

-(void)setBadgeNumber:(NSInteger)bNum{
    if(bNum<0){
        return;
    }
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:bNum];
    [JPUSHService setBadge:bNum];
}


#pragma mark CallbackMethods
/*
 回调方法name(data)  方法名为name，参数为 字典dict的转成的json字符串
 
 */

-(void) callbackJSONWithName:(NSString *)name Object:(id)obj{
    
    static NSString *plgName=@"uexJPush";
    uexPluginCallbackType type = uexPluginCallbackWithJsonString;
    //[EUtility uexPlugin:plgName callbackByName:name withObject:obj andType:type inTarget:cUexPluginCallbackInRootWindow];
    NSString *keyPath = [NSString stringWithFormat:@"%@.%@",plgName,name];
    [AppCanRootWebViewEngine() callbackWithFunctionKeyPath:keyPath arguments:ACArgsPack(@(type),obj)];
   
    
    
}



//测试用回调
-(void)occurrenceCallback:(NSString*)errorMsg{
    [self callbackJSONWithName:@"onEventOccured" Object:errorMsg];
}

@end
