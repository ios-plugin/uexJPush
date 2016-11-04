//
//  JPushInstance.m
//  EUExJPush
//
//  Created by AppCan on 15/5/18.
//  Copyright (c) 2015年 AppCan. All rights reserved.
//

#import "JPushInstance.h"



NSString *const uexJPushOnReceiveNotificationCallbackKey=@"onReceiveNotification";
NSString *const uexJPushOnReceiveNotificationOpenCallbackKey=@"onReceiveNotificationOpen";


@implementation JPushInstance {
    id _notification;
}





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
-(void)registerForRemoteNotification{
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
    //[JPUSHService setupWithOption:[JPushInstance sharedInstance].launchOptions appKey:@"68aa042143cb9962a777d0d9" channel:@"Publish channel" apsForProduction:FALSE];
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
    return userinfo;

}


//收到自定义消息
-(void)networkDidReceiveMessage:(NSNotification *)notification{
    NSDictionary * userInfo = [notification userInfo];
    NSMutableDictionary *dict=[NSMutableDictionary dictionary];
    NSString *content = [userInfo valueForKey:@"content"];
    [dict setValue:content forKey:@"message"];
    NSDictionary *extras = [userInfo valueForKey:@"extras"];
    [dict setValue:extras forKey:@"extras"];
    [self callbackJSONWithName:@"onReceiveMessage" Object:dict];
   
}

-(void)networkDidSetup:(NSNotification *)notification{
    self.connectionState=YES;
    NSMutableDictionary *dict=[NSMutableDictionary dictionary];
    [dict setValue:@"0" forKey:@"connect"];
    [self callbackJSONWithName:@"onReceiveConnectionChange" Object:dict];
}

-(void)networkDidClose:(NSNotification *)notification{
    self.connectionState=NO;
    NSMutableDictionary *dict=[NSMutableDictionary dictionary];
    [dict setValue:@"1" forKey:@"connect"];

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
                    alias:(NSString *)alias {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setValue:[NSString stringWithFormat:@"%i",iResCode] forKey:@"result"];
    switch (self.configStatus) {
        case AliasAndTagsConfigStatusBoth:
            [dict setValue:alias forKey:@"alias"];
            [dict setValue:[tags allObjects] forKey:@"tags"];
            [self callbackJSONWithName:@"cbSetAliasAndTags" Object:dict];
            break;
        case AliasAndTagsConfigStatusOnlyAlias :
            [dict setValue:alias forKey:@"alias"];
            [self callbackJSONWithName:@"cbSetAlias" Object:dict];
            break;
        case AliasAndTagsConfigStatusOnlyTags:
            [dict setValue:[tags allObjects] forKey:@"tags"];
            [self callbackJSONWithName:@"cbSetTags" Object:dict];
            break;
            
            
        case AliasAndTagsConfigStatusNeither: {
            break;
        }

    }
    self.configStatus=AliasAndTagsConfigStatusNeither;
}


-(void)setAlias:(NSString *)alias AndTags:(NSSet*)tags{

    [JPUSHService setTags:[JPUSHService filterValidTags:tags]
                 alias:alias
      callbackSelector:@selector(tagsAliasCallback:tags:alias:)
                object:self];
}





-(void)getRegistrationID{
    NSMutableDictionary *dict=[NSMutableDictionary dictionary];

    [dict setValue:[JPUSHService registrationID] forKey:@"registrationID"];
    [self callbackJSONWithName:@"cbGetRegistrationID" Object:dict];

}
-(void)getConnectionState{
    NSString *state=@"";
    if(self.connectionState){
        state=@"0";
    }else{
        state=@"1";
    }
    NSMutableDictionary *dict =[NSMutableDictionary dictionary];
    [dict setValue:state forKey:@"result"];
    [self callbackJSONWithName:@"cbGetConnectionState" Object:dict];
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
    _notification = nil;

}
-(void)callbackLocalNotificationiOS10:(UNNotificationContent*)content state:(UIApplicationState)state{
    switch (state) {
        case UIApplicationStateActive: {
            [self callbackJSONWithName:uexJPushOnReceiveNotificationCallbackKey Object:[self parseLocalNotificationiOS10:content]];
            break;
        }
        case UIApplicationStateInactive: {
            [self callbackJSONWithName:uexJPushOnReceiveNotificationOpenCallbackKey Object:[self parseLocalNotificationiOS10:content]];
            break;
        }
        case UIApplicationStateBackground: {
            
            break;
        }
            
    }
    _notification = nil;
}
-(NSDictionary *)parseLocalNotificationiOS10:(UNNotificationContent*)content{
    NSNumber *badge = content.badge?:@(0);  // 推送消息的角标
    NSString *body = content.body?:@"";    // 推送消息体
    NSString *subtitle = content.subtitle?:@"";  // 推送消息的副标题
    NSString *title = content.title?:@"";  // 推送消息的标题

    
    NSMutableDictionary *dict=[NSMutableDictionary dictionary];
    [dict setValue:badge forKey:@"badge"];
    [dict setValue:title forKey:@"title"];
    [dict setValue:subtitle forKey:@"subtitle"];
    [dict setValue:body forKey:@"content"];
    [dict setValue:@(NO) forKey:@"isAPNs"];
    return dict;
    
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

- (void)addLocalNotificationWithbroadCastTime:(NSDate*)time timeInterval:(NSTimeInterval)timeInterval
                               notificationId:(NSString*)ID
                                      content:(NSString *)body
                                       extras:(NSDictionary *)extras
                                        title:(NSString *)title{

    JPushNotificationContent *content = [[JPushNotificationContent alloc] init];
    content.title = title;
    content.userInfo = extras;
    content.body = body;
    content.badge = @(-1);
    JPushNotificationTrigger *trigger = [[JPushNotificationTrigger alloc] init];
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 10.0) {
        trigger.timeInterval = timeInterval; // iOS10以上有效
    }
    else {
        trigger.fireDate = time; // iOS10以下有效
    }
    JPushNotificationRequest *request = [[JPushNotificationRequest alloc] init];
    request.content = content;
    request.trigger = trigger;
    request.requestIdentifier = ID;
    request.completionHandler = ^(id result) {
        NSLog(@"%@--%@", result,[result class]); // iOS10以上成功则result为UNNotificationRequest对象，失败则result为nil;iOS10以下成功result为UILocalNotification对象，失败则result为nil
        _notification = result;
        
    };
    [JPUSHService addNotification:request];
}



-(void)removeLocalNotification:(NSString*)ID{
    if (_notification) {
        NSLog(@"notification:%@====",_notification);
            JPushNotificationIdentifier *identifier = [[JPushNotificationIdentifier alloc] init];
        
            if ([[[UIDevice currentDevice] systemVersion] floatValue] < 10.0) {
                identifier.notificationObj = (UILocalNotification*)_notification;
            }
            else {
#ifdef NSFoundationVersionNumber_iOS_9_x_Max
                UNNotificationRequest *request = _notification;
                identifier.identifiers = @[ID];
                identifier.delivered = YES;
                 NSLog(@"identifier.identifiers:%@==%@",request.identifier,ID);
#endif
            }
       
           [JPUSHService removeNotification:identifier];
            _notification = nil;
        
       
        
    }
   
    
}

-(void)clearLocalNotifications{
   
    [JPUSHService removeNotification:nil];
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
    [EUtility uexPlugin:plgName callbackByName:name withObject:obj andType:type inTarget:cUexPluginCallbackInRootWindow];
    
    

    
}





//测试用回调
-(void)occurrenceCallback:(NSString*)errorMsg{
    [self callbackJSONWithName:@"onEventOccured" Object:errorMsg];
}

@end
