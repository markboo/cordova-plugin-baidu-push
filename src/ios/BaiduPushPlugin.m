
#import "BaiduPushPlugin.h"
#import "BPush.h"

#ifdef NSFoundationVersionNumber_iOS_9_x_Max
#import <UserNotifications/UserNotifications.h>
#endif

@implementation BaiduPushPlugin{
    NSNotificationCenter *_observer;
}

@synthesize handlerObj;
@synthesize callbackId;
@synthesize appkey;

- (void)registerChannel: (CDVInvokedUrlCommand*)command
{
    //初始化持久callbackId
    self.callbackId = command.callbackId;
    
    if( command.arguments.count ) {
        self.appkey = [command.arguments objectAtIndex:0];
    }

    //注册通道
    [BPush registerChannel:nil apiKey:self.appkey pushMode:BPushModeDevelopment withFirstAction:nil withSecondAction:nil withCategory:nil useBehaviorTextInput:YES isDebug:YES];
}

//绑定通道等待处理推送
- (void)bindChannel: (CDVInvokedUrlCommand*)command
{
    //初始化持久callbackId
    self.callbackId = command.callbackId;
    //如果有推送通知
    if( self.notificationMessage ){
        //创建结果
        CDVPluginResult *commandResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:self.notificationMessage];
        
        //允许多次回调
        [commandResult setKeepCallbackAsBool:YES];
        //向Cordova前端回调
        [self.commandDelegate sendPluginResult:commandResult callbackId:command.callbackId];
    }
}

- (void)unregister:(CDVInvokedUrlCommand*)command
{
}

- (void) notificationReceived: (NSDictionary *) message
{
    CDVPluginResult *commandResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:self.notificationMessage];
    //允许多次回调
    [commandResult setKeepCallbackAsBool:YES];
    [self.commandDelegate sendPluginResult:commandResult callbackId:self.callbackId];
}

- (void)notificationReceived
{
    NSString* message = [NSString stringWithFormat:@"my dictionary is %@", self.notificationMessage];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"启动提示" message:message delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:nil];
    [alert show];
}

/*!
 @method
 @abstract 绑定
 */
- (void)startWork:(CDVInvokedUrlCommand*)command
{
    _observer = [[NSNotificationCenter defaultCenter] addObserverForName:CDVRemoteNotification
      object:nil
      queue:[NSOperationQueue mainQueue]
      usingBlock:^(NSNotification *note) {
          NSData *deviceToken = [note object];
          //在 App 启动时注册百度云推送服务，需要提供 Apikey
          [BPush registerDeviceToken:deviceToken];
          
          [BPush bindChannelWithCompleteHandler:^(id result, NSError *error) {
              //绑定返回值
              if ([self returnBaiduResult:result]) {
                  self.result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:result];
              } else {
                  self.result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:result];
              }
              [[NSNotificationCenter defaultCenter] removeObserver:_observer];
              [self.commandDelegate sendPluginResult:self.result callbackId:command.callbackId];
          }];
    }];
    
    //iOS10 下需要使用新的 API
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 10.0) {
        
#ifdef NSFoundationVersionNumber_iOS_9_x_Max
        UNUserNotificationCenter* center = [UNUserNotificationCenter currentNotificationCenter];
        
        [center requestAuthorizationWithOptions:(UNAuthorizationOptionAlert + UNAuthorizationOptionSound + UNAuthorizationOptionBadge) completionHandler:^(BOOL granted, NSError * _Nullable error) {
            //Enable or disable features based on authorization.
            if (granted) {
                [[UIApplication sharedApplication] registerForRemoteNotifications];
            }
        }];
#endif
        
    } else if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0) {
        UIUserNotificationType myTypes = UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert;
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:myTypes categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
    } else {
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wdeprecated-declarations"
        UIRemoteNotificationType myTypes = UIRemoteNotificationTypeBadge|UIRemoteNotificationTypeAlert|UIRemoteNotificationTypeSound;
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:myTypes];
#pragma GCC diagnostic pop
    }
}

/*!
 @method
 @abstract 解除绑定
 */
- (void)stopWork:(CDVInvokedUrlCommand*)command
{
    [BPush unbindChannelWithCompleteHandler:^(id result, NSError *error) {
        // 解绑返回值
        if ([self returnBaiduResult:result])
        {
            self.result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
        }
        else{
            self.result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
        }
        [self.commandDelegate sendPluginResult:self.result callbackId:command.callbackId];
    }];
}

/*!
 @method
 @abstract 回复绑定
 */
- (void)resumeWork:(CDVInvokedUrlCommand*)command
{
    NSLog(@"回复绑定");
    
    self.callbackId = command.callbackId;
    
    if(self.notificationMessage){
        
        CDVPluginResult *commandResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:self.notificationMessage];
        
        //允许多次回调
        [commandResult setKeepCallbackAsBool:YES];
        [self.commandDelegate sendPluginResult:commandResult callbackId:command.callbackId];
    }
}

/*!
@method
@abstract 设置Tag
*/
- (void)setTags:(CDVInvokedUrlCommand*)command
{
    NSLog(@"设置Tag");
    NSString *tagsString = command.arguments[0];
    
    if (![self checkTagString:tagsString]) {
        self.result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
        [self.commandDelegate sendPluginResult:self.result callbackId:command.callbackId];
        return;
    }
    
    NSArray *tags = [tagsString componentsSeparatedByString:@","];
    if (tags) {
        [BPush setTags:tags withCompleteHandler:^(id result, NSError *error) {
            // 设置多个标签组的返回值
            if ([self returnBaiduResult:result])
            {
                self.result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
            }
            else{
                self.result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
            }
            [self.commandDelegate sendPluginResult:self.result callbackId:command.callbackId];
        }];
    }
}

/*!
 @method
 @abstract 删除Tag
 */
- (void)delTags:(CDVInvokedUrlCommand*)command
{
    NSLog(@"删除Tag");
    NSString *tagsString = command.arguments[0];
    if (![self checkTagString:tagsString]) {
        self.result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
        [self.commandDelegate sendPluginResult:self.result callbackId:command.callbackId];
        return;
    }
    
    NSArray *tags = [tagsString componentsSeparatedByString:@","];
    if (tags) {
        [BPush delTags:tags withCompleteHandler:^(id result, NSError *error) {
            // 删除标签的返回值
            if ([self returnBaiduResult:result])
            {
                self.result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
            }
            else{
                self.result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
            }
            [self.commandDelegate sendPluginResult:self.result callbackId:command.callbackId];
        }];
    }
}

/*
* 设置应用图标数字
*/
- (void)setApplicationIconBadgeNumber:(CDVInvokedUrlCommand *)command
{
    if( command.arguments.count ) {
        
        NSString *badge = [command.arguments objectAtIndex:0];
        
        [[UIApplication sharedApplication] setApplicationIconBadgeNumber:badge.intValue];
        
        NSString* message = [NSString stringWithFormat:@"app badge count set to %@", badge];
        CDVPluginResult *commandResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:message];
        
        [self.commandDelegate sendPluginResult:commandResult callbackId:command.callbackId];
    }
 }

/*
* 获取应用图标数字
*/
- (void)getApplicationIconBadgeNumber:(CDVInvokedUrlCommand *)command
{
    NSInteger badge = [UIApplication sharedApplication].applicationIconBadgeNumber;
    
    CDVPluginResult *commandResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsInt:(int)badge];
    
    [self.commandDelegate sendPluginResult:commandResult callbackId:command.callbackId];
}

- (void)clearAllNotifications:(CDVInvokedUrlCommand *)command
{
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    
    NSString* message = [NSString stringWithFormat:@"cleared all notifications"];
    CDVPluginResult *commandResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:message];
    [self.commandDelegate sendPluginResult:commandResult callbackId:command.callbackId];
}

- (void)hasPermission:(CDVInvokedUrlCommand *)command
{
    BOOL enabled = NO;
    
    id<UIApplicationDelegate> appDelegate = [UIApplication sharedApplication].delegate;
    
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wundeclared-selector"
    if ([appDelegate respondsToSelector:@selector(userHasRemoteNotificationsEnabled)]) {
        enabled = [appDelegate performSelector:@selector(userHasRemoteNotificationsEnabled)];
    }
#pragma GCC diagnostic pop
    
    NSMutableDictionary* message = [NSMutableDictionary dictionaryWithCapacity:1];
    [message setObject:[NSNumber numberWithBool:enabled] forKey:@"isEnabled"];
    
    CDVPluginResult *commandResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:message];
    [self.commandDelegate sendPluginResult:commandResult callbackId:command.callbackId];
}

- (BOOL)checkTagString:(NSString *)tagStr {
    NSString *str = [tagStr stringByReplacingOccurrencesOfString:@"," withString:@""];
    if ([str isEqualToString:@""]) {
        return NO;
    }
    return YES;
}

- (BOOL)returnBaiduResult:(id)result{
    NSString *resultStr = result[@"error_code"];
    if (!resultStr || [[resultStr description] isEqualToString:@"0"]){
        return YES;
    }
    return NO;
}

@end
