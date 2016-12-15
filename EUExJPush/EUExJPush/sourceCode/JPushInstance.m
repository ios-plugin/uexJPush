//
//  JPushInstance.m
//  EUExJPush
//
//  Created by AppCan on 15/5/18.
//  Copyright (c) 2015年 AppCan. All rights reserved.
//

#import "JPushInstance.h"
#import <AppCanKit/ACEXTScope.h>


static NSString *const kReceiveNotificationCallbackKeyPath = @"uexJPush.onReceiveNotification";
static NSString *const kReceiveNotificationOpenCallbackKeyPath = @"uexJPush.onReceiveNotificationOpen";



@interface JPushInstance ()
@property (nonatomic,strong)NSMutableDictionary *managedNotifications;
@property (nonatomic,strong)void (^notificationLaunchBlock)();

@end
@implementation JPushInstance






#pragma mark sharedInstance
+ (instancetype) sharedInstance{
    static JPushInstance *sharedObj= nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedObj=[[self alloc]init];
    });
    return sharedObj;
}



- (instancetype)init{
    if (self = [super init]){
        [self activateNotifications];
        _showNotificationAlertInForeground = YES;
        _managedNotifications = [NSMutableDictionary dictionary];
    }
    
    return self;

}



#pragma mark - JPushEvent

-(void)activateNotifications{
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

//收到自定义消息
-(void)networkDidReceiveMessage:(NSNotification *)notification{
    NSDictionary * userInfo = notification.userInfo;
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setValue:userInfo[@"content"] forKey:@"message"];
    [dict setValue:userInfo[@"extras"] forKey:@"extras"];
    [AppCanRootWebViewEngine() callbackWithFunctionKeyPath:@"uexJPush.onReceiveMessage" arguments:ACArgsPack(dict.ac_JSONFragment)];
    
    
}

-(void)networkDidSetup:(NSNotification *)notification{
    self.connectionState = YES;
    [AppCanRootWebViewEngine() callbackWithFunctionKeyPath:@"uexJPush.onReceiveConnectionChange" arguments:ACArgsPack(@{@"connect": @0}.ac_JSONFragment)];
    
}

-(void)networkDidClose:(NSNotification *)notification{
    self.connectionState = NO;
    [AppCanRootWebViewEngine() callbackWithFunctionKeyPath:@"uexJPush.onReceiveConnectionChange" arguments:ACArgsPack(@{@"connect": @1}.ac_JSONFragment)];
}

-(void)networkDidRegister:(NSNotification *)notification{
    
    
}
-(void)networkDidLogin:(NSNotification *)notification{
    NSMutableDictionary *dict=[NSMutableDictionary dictionary];
    [dict setValue:[JPUSHService registrationID] forKey:@"title"];
    [AppCanRootWebViewEngine() callbackWithFunctionKeyPath:@"uexJPush.onReceiveRegistration" arguments:ACArgsPack(dict.ac_JSONFragment)];
    
    
}
-(void)serviceError:(NSNotification *)notification{
    ACLogError(@"JPUSH: serviceError: %@",notification.userInfo);
}


#pragma mark - System Event

- (void)notifyApplication:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"PushConfig" ofType:@"plist"];
    NSDictionary *data = [NSDictionary dictionaryWithContentsOfFile:path];
    
    NSString *appKey = [data objectForKey:@"APP_KEY"];
    NSString *channel = [data objectForKey:@"CHANNEL"];
    NSString *apsForProduction = [data objectForKey:@"APS_FOR_PRODUCTION"];
    BOOL isProduction = (apsForProduction.integerValue != 0);
    [JPUSHService setupWithOption:launchOptions appKey:appKey channel:channel apsForProduction:isProduction];

    
    
    NSDictionary *result = nil;
    if (launchOptions[UIApplicationLaunchOptionsRemoteNotificationKey]) {
        result = [self parseRemoteNotification:launchOptions[UIApplicationLaunchOptionsRemoteNotificationKey]];
    }
    if (launchOptions[UIApplicationLaunchOptionsLocalNotificationKey]) {
        result = [self parseLocalNotification:launchOptions[UIApplicationLaunchOptionsLocalNotificationKey]];
    }
    
    if (result) {
        ACLogError(@"set notificationLaunchBlock");
        self.notificationLaunchBlock = ^{
            [AppCanRootWebViewEngine() callbackWithFunctionKeyPath:kReceiveNotificationOpenCallbackKeyPath arguments:ACArgsPack(result.ac_JSONFragment)];
        };
    }


}

- (void)notifyRootPageDidFinishLoading{
    if (!(ACLogGlobalLogMode & ACLogLevelDebug)) {
        [JPUSHService setLogOFF];
    }
    if (self.notificationLaunchBlock) {
        self.notificationLaunchBlock();
        self.notificationLaunchBlock = nil;
    }
    if (ACSystemVersion() >= 10.0) {
        JPUSHRegisterEntity * entity = [[JPUSHRegisterEntity alloc] init];
        entity.types = UNAuthorizationOptionAlert|UNAuthorizationOptionBadge|UNAuthorizationOptionSound;
        [JPUSHService registerForRemoteNotificationConfig:entity delegate:self];

    }else{
        [JPUSHService registerForRemoteNotificationTypes:(UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert)
                                              categories:nil];
    }

    [JPUSHService registrationIDCompletionHandler:^(int resCode, NSString *registrationID) {
        ACLogDebug(@"JPush -> fetch registrationID resCode:%@, id: %@",@(resCode),registrationID);
    }];

    
}

- (void)notifyApplication:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken{
    
    [JPUSHService registerDeviceToken:deviceToken];
}



- (void)notifyApplication:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification{
    NSString *keyPath = (application.applicationState == UIApplicationStateInactive) ? kReceiveNotificationOpenCallbackKeyPath : kReceiveNotificationCallbackKeyPath;
    NSDictionary *result = [self parseLocalNotification:notification];
    [AppCanRootWebViewEngine() callbackWithFunctionKeyPath:keyPath arguments:ACArgsPack(result.ac_JSONFragment)];
    
}


- (NSDictionary *)parseLocalNotification:(UILocalNotification*)notification{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    NSMutableDictionary *extras = [NSMutableDictionary dictionary];
    NSDictionary *info = notification.userInfo;
    [info enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        if([key isEqual:@"__JPFNotificationKey"]){
            [dict setValue:obj forKey:@"notificationId"];
        }else{
            [extras setValue:obj forKey:key];
        }
    }];
    [dict setValue:notification.alertTitle forKey:@"title"];
    [dict setValue:extras forKey:@"extras"];
    [dict setValue:notification.alertBody forKey:@"content"];
    [dict setValue:@(NO) forKey:@"isAPNs"];
    return dict;
}





- (void)notifyApplication:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler{
    if (!userInfo[@"_j_msgid"]) {
        return;
    }
    [self notifyApplication:application didReceiveRemoteNotification:userInfo];
    completionHandler(UIBackgroundFetchResultNewData);
}

- (void)notifyApplication:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo{
    if (!userInfo[@"_j_msgid"]) {
        return;
    }
    
    NSString *keyPath = (application.applicationState == UIApplicationStateInactive) ? kReceiveNotificationOpenCallbackKeyPath : kReceiveNotificationCallbackKeyPath;
    NSDictionary *result = [self parseRemoteNotification:userInfo];
    [AppCanRootWebViewEngine() callbackWithFunctionKeyPath:keyPath arguments:ACArgsPack(result.ac_JSONFragment)];
    
    [JPUSHService handleRemoteNotification:userInfo];
}

- (NSDictionary *)parseRemoteNotification:(NSDictionary *)userInfo{
    ACLogError(@"parseRemoteNotification: %@",userInfo);

    NSMutableDictionary *result = [NSMutableDictionary dictionary];
    NSMutableDictionary *extras = [NSMutableDictionary dictionary];
    
    [userInfo enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        if (![key isEqual:@"aps"] && ![key isEqual:@"_j_msgid"]) {
            [extras setValue:obj forKey:key];
        }
    }];
    
    id alert = userInfo[@"aps"][@"alert"];
    if ([alert isKindOfClass:[NSDictionary class]]) {
        [result setValue:alert[@"body"] forKey:@"content"];
        [result setValue:alert[@"title"] forKey:@"title"];
        [result setValue:alert[@"subtitle"] forKey:@"subtitle"];
    }
    if ([alert isKindOfClass:[NSString class]]) {
        [result setValue:alert forKey:@"content"];
    }
    [result setValue:extras forKey:@"extras"];
    [result setValue:@(YES) forKey:@"isAPNs"];
    [result setValue:userInfo[@"_j_msgid"] forKey:@"_j_msgid"];

    return result;
}


#pragma mark - JPUSHRegisterDelegate
//App处于前台接收通知时
- (void)jpushNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(NSInteger))completionHandler {

    
    NSDictionary *result = [self parseUserNotification:notification];

    
    [AppCanRootWebViewEngine() callbackWithFunctionKeyPath:kReceiveNotificationCallbackKeyPath arguments:ACArgsPack(result.ac_JSONFragment)];
    UNNotificationPresentationOptions option = self.showNotificationAlertInForeground ? UNNotificationPresentationOptionBadge|UNNotificationPresentationOptionSound|UNNotificationPresentationOptionAlert : 0 ;

    
    completionHandler(option);

}
////App通知的点击事件
- (void)jpushNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)())completionHandler {
    
    NSDictionary *result = [self parseUserNotification:response.notification];

    [AppCanRootWebViewEngine() callbackWithFunctionKeyPath:kReceiveNotificationOpenCallbackKeyPath arguments:ACArgsPack(result.ac_JSONFragment)];

    
    completionHandler();
}






- (NSDictionary *)parseUserNotification:(UNNotification *)notification{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    NSMutableDictionary *extras = [NSMutableDictionary dictionary];
    UNNotificationContent *content = notification.request.content;
    
    [content.userInfo enumerateKeysAndObjectsUsingBlock:^(NSString *_Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        if (![key isEqual:@"aps"] && ![key isEqual:@"_j_msgid"]) {
            [extras setValue:obj forKey:key];
        }
    }];
    BOOL isAPNS = [notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]];
    if (isAPNS) {
        [JPUSHService handleRemoteNotification:content.userInfo];
    }else{
        [dict setValue:notification.request.identifier forKey:@"notificationId"];
    }
    
    
    [dict setValue:content.badge forKey:@"badge"];
    [dict setValue:content.title forKey:@"title"];
    [dict setValue:content.subtitle forKey:@"subtitle"];
    [dict setValue:content.body forKey:@"content"];
    [dict setValue:@(isAPNS) forKey:@"isAPNs"];
    [dict setValue:extras forKey:@"extras"];
    [dict setValue:content.userInfo[@"_j_msgid"] forKey:@"_j_msgid"];
    return dict;
}










#pragma mark LocalNotifications



- (void)addLocalNotificationWithTimeInterval:(NSTimeInterval)timeInterval
                               notificationId:(NSString *)ID
                                      content:(NSString *)body
                                       extras:(NSDictionary *)extras
                                        title:(NSString *)title{

    JPushNotificationContent *content = [[JPushNotificationContent alloc] init];
    content.title = title;
    content.userInfo = extras;
    content.body = body;
    content.badge = @(-1);
    JPushNotificationTrigger *trigger = [[JPushNotificationTrigger alloc] init];
    if (ACSystemVersion() >= 10.0) {
        trigger.timeInterval = timeInterval; // iOS10以上有效
    }
    else {
        trigger.fireDate = [NSDate dateWithTimeIntervalSinceNow:timeInterval]; // iOS10以下有效
    }
    JPushNotificationRequest *request = [[JPushNotificationRequest alloc] init];
    request.content = content;
    request.trigger = trigger;
    request.requestIdentifier = ID;
    request.completionHandler = ^(id result) {
        [self.managedNotifications setValue:result forKey:ID];
    };
    [JPUSHService addNotification:request];
}

- (void)removeAllLocalNotifications{
    [JPUSHService removeNotification:nil];
    [self.managedNotifications removeAllObjects];
}

- (void)removeLocalNotificationWithID:(NSString *)ID{
    id notification = self.managedNotifications[ID];
    if (!notification) {
        return;
    }
    JPushNotificationIdentifier *identifier = [[JPushNotificationIdentifier alloc] init];
    if (ACSystemVersion() < 10) {
        identifier.notificationObj = notification;
    }else{
        identifier.identifiers = @[((UNNotificationRequest *)notification).identifier];
    }
    [JPUSHService removeNotification:identifier];
    
}


#pragma mark badge number

- (void)setBadgeNumber:(NSInteger)badgeNumber{
    if( badgeNumber < 0){
        return;
    }
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:badgeNumber];
    [JPUSHService setBadge:badgeNumber];
}







@end
