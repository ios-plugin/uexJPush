//
//  JPushInstance.m
//  EUExJPush
//
//  Created by AppCan on 15/5/18.
//  Copyright (c) 2015年 AppCan. All rights reserved.
//

#import "JPushInstance.h"
#import "APService.h"
static JPushInstance *sharedObj = nil;
@implementation JPushInstance





#pragma mark sharedInstance
+ (instancetype) sharedInstance
{
    @synchronized (self)
    {
        if (sharedObj == nil)
        {
            [[self alloc] init];
        }
    }
    return sharedObj;
}

+ (id) allocWithZone:(NSZone *)zone
{
    @synchronized (self) {
        if (sharedObj == nil) {
            sharedObj = [super allocWithZone:zone];
            return sharedObj;
        }
    }
    return nil;
}

- (id) copyWithZone:(NSZone *)zone
{
    return self;
}

- (id) retain
{
    return self;
}

- (NSUInteger) retainCount
{
    return UINT_MAX;
}

- (oneway void) release
{
    
}

- (id) autorelease
{
    return self;
}

- (id)init
{
    @synchronized(self) {
        if (self = [super init]){
            self.connectionState =NO;
            self.configStatus=Neither;
            [self activateNotifications];
            
        }
        
        return nil;
    }
}


#pragma mark Notifications

extern NSString * const kJPFNetworkDidSetupNotification;          // 建立连接

extern NSString * const kJPFNetworkDidCloseNotification;          // 关闭连接

extern NSString * const kJPFNetworkDidRegisterNotification;       // 注册成功

extern NSString * const kJPFNetworkDidLoginNotification;          // 登录成功

extern NSString * const kJPFNetworkDidReceiveMessageNotification; // 收到消息(非APNS)

extern NSString *const kJPFServiceErrorNotification;  // 错误提示


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
+(void)callBackRemoteNotification:(NSDictionary*)userinfo{
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
 
    [dict setValue:extras forKey:@"extras"];
    NSString *result=[dict JSONFragment];
    NSString *jsSuccessStr = [NSString stringWithFormat:@"if(uexJPush.onReceiveNotification != null){uexJPush.onReceiveNotification('%@');}",result];
    [EUtility evaluatingJavaScriptInRootWnd:jsSuccessStr];
}




//收到自定义消息
-(void)networkDidReceiveMessage:(NSNotification *)notification{
    NSDictionary * userInfo = [notification userInfo];
    NSMutableDictionary *dict=[NSMutableDictionary dictionary];
    NSString *content = [userInfo valueForKey:@"content"];
    [dict setValue:content forKey:@"message"];
    NSDictionary *extras = [userInfo valueForKey:@"extras"];
    [dict setValue:extras forKey:@"extras"];
    [self callBackJsonWithName:@"onReceiveMessage" Object:dict];
   
}

-(void)networkDidSetup:(NSNotification *)notification{
    self.connectionState=YES;
    NSMutableDictionary *dict=[NSMutableDictionary dictionary];
    [dict setValue:@"0" forKey:@"connect"];
    [self callBackJsonWithName:@"onReceiveConnectionChange" Object:dict];
}

-(void)networkDidClose:(NSNotification *)notification{
    self.connectionState=NO;
    NSMutableDictionary *dict=[NSMutableDictionary dictionary];
    [dict setValue:@"1" forKey:@"connect"];
    [self callBackJsonWithName:@"onReceiveConnectionChange" Object:dict];
}

-(void)networkDidRegister:(NSNotification *)notification{

   
}
-(void)networkDidLogin:(NSNotification *)notification{
    NSMutableDictionary *registrationDict=[NSMutableDictionary dictionary];
    [registrationDict setValue:[APService registrationID] forKey:@"title"];
    [self callBackJsonWithName:@"onReceiveRegistration" Object:registrationDict];
    
}
-(void)serviceError:(NSNotification *)notification{
    [self occurrenceCallBack:[NSString stringWithFormat:@"Service Error : %@",notification.userInfo]];
}






#pragma mark alias&tags
- (void)tagsAliasCallback:(int)iResCode
                     tags:(NSSet *)tags
                    alias:(NSString *)alias {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setValue:[NSString stringWithFormat:@"%i",iResCode] forKey:@"result"];
    switch (self.configStatus) {
        case Both:
            [dict setValue:alias forKey:@"alias"];
            [dict setValue:[tags allObjects] forKey:@"tags"];
            [self callBackJsonWithName:@"cbSetAliasAndTags" Object:dict];
            break;
        case OnlyAlias :
            [dict setValue:alias forKey:@"alias"];
            [self callBackJsonWithName:@"cbSetAlias" Object:dict];
            break;
        case OnlyTags:
            [dict setValue:[tags allObjects] forKey:@"tags"];
            [self callBackJsonWithName:@"cbSetTags" Object:dict];
            break;
            
        default:
            break;
    }
    self.configStatus=Neither;
}


-(void)setAlias:(NSString *)alias AndTags:(NSSet*)tags{

    [APService setTags:[APService filterValidTags:tags]
                 alias:alias
      callbackSelector:@selector(tagsAliasCallback:tags:alias:)
                object:self];
}





-(void)getRegistrationID{
    NSMutableDictionary *dict=[NSMutableDictionary dictionary];

    [dict setValue:[APService registrationID] forKey:@"registrationID"];
    [self callBackJsonWithName:@"cbGetRegistrationID" Object:dict];

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
    [self callBackJsonWithName:@"cbGetConnectionState" Object:dict];
}
#pragma mark LocalNotifications

+(void)callBackLocalNotification:(UILocalNotification*)notification{
   [APService showLocalNotificationAtFront:notification identifierKey:nil];
}



-(void)addLocalNotificationWithbroadCastTime:(NSDate*)time
                              notificationId:(NSString*)ID
                                     content:(NSString *)content
                                      extras:(NSDictionary *)extras{
    
    
    [APService setLocalNotification:time
                          alertBody:content
                              badge:-1
                        alertAction:nil
                      identifierKey:ID
                           userInfo:extras
                          soundName:nil];
}



-(void)removeLocalNotification:(NSString*)ID{
    [APService deleteLocalNotificationWithIdentifierKey:ID];
}

-(void)clearLocalNotifications{
    [APService clearAllLocalNotifications];
}

#pragma mark CallBackMethods
/*
 回调方法name(data)  方法名为name，参数为 字典dict的转成的json字符串
 
 */
-(void) callBackJsonWithName:(NSString *)name Object:(id)dict{
    

    
    

    /*
     
     
     
     if([NSJSONSerialization isValidJSONObject:dict]){
     NSError *error;
     NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict
     options:NSJSONWritingPrettyPrinted
     error:&error
     ];
     
     NSString *result = [[NSString alloc] initWithData:jsonData  encoding:NSUTF8StringEncoding];
     */
    NSString *result=[dict JSONFragment];
    NSString *jsSuccessStr = [NSString stringWithFormat:@"if(uexJPush.%@ != null){uexJPush.%@('%@');}",name,name,result];
    
    [self performSelectorOnMainThread:@selector(callBack:) withObject:jsSuccessStr waitUntilDone:YES];
    
}

-(void)callBack:(NSString *)str{
    [self performSelector:@selector(delayedCallBack:) withObject:str afterDelay:0.01];
    //[meBrwView stringByEvaluatingJavaScriptFromString:str];
}

-(void)delayedCallBack:(NSString *)str{
    [EUtility evaluatingJavaScriptInRootWnd:str];
}


//测试用回调
-(void)occurrenceCallBack:(NSString*)errorMsg{
    [self callBackJsonWithName:@"onEventOccured" Object:errorMsg];
}

@end
