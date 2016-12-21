//
//  AppDelegate+DesintonNotification.m
//  Desinton
//
//  Created by markboo on 2016/12/16.
//
//

#import "AppDelegate+DesintonNotification.h"
#import <objc/runtime.h>
#import "BPush.h"
#import "BaiduPushPlugin.h"

#ifdef NSFoundationVersionNumber_iOS_9_x_Max
#import <UserNotifications/UserNotifications.h>
#endif

@implementation AppDelegate (notification)

+ (void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class class = [self class];
        
        SEL originalSelector = @selector(init);
        SEL swizzledSelector = @selector(pushPluginSwizzledInit);
        
        Method original = class_getInstanceMethod(class, originalSelector);
        Method swizzled = class_getInstanceMethod(class, swizzledSelector);
        
        BOOL didAddMethod =
        class_addMethod(class,
                        originalSelector,
                        method_getImplementation(swizzled),
                        method_getTypeEncoding(swizzled));
        
        if (didAddMethod) {
            class_replaceMethod(class,
                                swizzledSelector,
                                method_getImplementation(original),
                                method_getTypeEncoding(original));
        } else {
            method_exchangeImplementations(original, swizzled);
        }
    });
}

- (AppDelegate *)pushPluginSwizzledInit
{
    [[NSNotificationCenter defaultCenter]
             addObserver:self
             selector:@selector(applicationDidBecomeActive:)
             name:UIApplicationDidBecomeActiveNotification
             object:nil]; //监听是否重新进入程序程序.
    
    return [self pushPluginSwizzledInit];
}

//应用重新启动后执行
- (void)applicationDidBecomeActive:(NSNotification *)notification
{
}

//应用启动完成时执行
- (BOOL)application:(UIApplication*)application didFinishLaunchingWithOptions:(NSDictionary*)launchOptions
{
    //自己点击启动
    if(!launchOptions) {
        NSLog(@"点击app启动");
    } else {
        NSURL *url = [launchOptions objectForKey:UIApplicationLaunchOptionsURLKey];
        //app 通过urlscheme启动
        if (url) {
        }
        
        UILocalNotification *localNotification = [launchOptions objectForKey:UIApplicationLaunchOptionsLocalNotificationKey];
        //通过本地通知启动,app 通过本地通知启动
        if(localNotification) {
        }
        
        NSDictionary *remoteCotificationDic = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
        //App是用户点击推送消息启动,app 通过远程推送通知启动
        if(remoteCotificationDic) {
            NSDictionary *remoteCotificationDic = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
            [BPush handleNotification:remoteCotificationDic];
        }
    }

    //角标清0
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    return [super application:application didFinishLaunchingWithOptions:launchOptions];
}

//App收到推送的通知，IOS7以上版本使用
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    
    // 应用在前台，不跳转页面，让用户选择。
    if ( application.applicationState == UIApplicationStateActive ) {
        
        BaiduPushPlugin *baiduPushPlugin = [self.viewController.commandDelegate getCommandInstance:@"BaiduPush"];
        baiduPushPlugin.notificationMessage = userInfo;
        [baiduPushPlugin notificationReceived:@"应用在前台，不跳转页面，让用户选择"];
        
        completionHandler(UIBackgroundFetchResultNewData);
        
    } else { //杀死状态下，直接跳转到跳转页面。
        
        long silent = 0;
        id aps = [userInfo objectForKey:@"aps"];
        
        //如果只携带content-available: 1 不携带任何badge，sound和消息内容等参数，
        //则可以不打扰用户的情况下进行内容更新等操作即为“Silent Remote Notifications”(静默推送)。
        id contentAvailable = [aps objectForKey:@"content-available"];
        
        if ([contentAvailable isKindOfClass:[NSString class]] && [contentAvailable isEqualToString:@"1"]) {
            silent = 1;
        } else if ([contentAvailable isKindOfClass:[NSNumber class]]) {
            silent = [contentAvailable integerValue];
        }
        
        if ( silent == 1 ) {
            
            void (^safeHandler)(UIBackgroundFetchResult) = ^(UIBackgroundFetchResult result){
                dispatch_async(dispatch_get_main_queue(), ^{
                    completionHandler(result);
                });
            };
            
            //UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"启动提示" message:@"杀死状态下，直接跳转到跳转页面2" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:nil];
            //[alert show];
            
            BaiduPushPlugin *baiduPushPlugin = [self.viewController.commandDelegate getCommandInstance:@"BaiduPush"];
            
            id notId = [userInfo objectForKey:@"notId"];
            if (notId != nil) {
                NSLog(@"Push Plugin notId %@", notId);
                [baiduPushPlugin.handlerObj setObject:safeHandler forKey:notId];
            } else {
                NSLog(@"Push Plugin notId handler");
                [baiduPushPlugin.handlerObj setObject:safeHandler forKey:@"handler"];
            }
            baiduPushPlugin.notificationMessage = userInfo;
            
            [baiduPushPlugin notificationReceived:@"杀死状态下，直接跳转到跳转页面"];
            
        } else { //杀死状态下，直接跳转到跳转页面
            
            BaiduPushPlugin *baiduPushPlugin = [self.viewController.commandDelegate getCommandInstance:@"BaiduPush"];
            baiduPushPlugin.notificationMessage = userInfo;
            [baiduPushPlugin notificationReceived:@"杀死状态下，直接跳转到跳转页面"];
            
            completionHandler(UIBackgroundFetchResultNewData);
            
        }
    }
}

//App收到推送的通知，IOS7以下版本使用
- (void) application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    [BPush handleNotification:userInfo];
    
    //应用在前台 或者后台开启状态下，不跳转页面，让用户选择。
    if (application.applicationState == UIApplicationStateActive || application.applicationState == UIApplicationStateBackground) {
        BaiduPushPlugin *baiduPushPlugin = [self.viewController.commandDelegate getCommandInstance:@"BaiduPush"];
        [baiduPushPlugin notificationReceived:@"后台开启状态"];
    } else { //杀死状态下，直接跳转到跳转页面。
        BaiduPushPlugin *baiduPushPlugin = [self.viewController.commandDelegate getCommandInstance:@"BaiduPush"];
        [baiduPushPlugin notificationReceived:@"杀死状态"];
    }
}

// 在 iOS8 系统中，还需要添加这个方法。通过新的 API 注册推送服务
- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings
{
    [application registerForRemoteNotifications];
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    [[NSNotificationCenter defaultCenter] postNotificationName:CDVRemoteNotification object:deviceToken];
}

//DeviceToken 获取失败
- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    NSLog(@"DeviceToken 获取失败，原因：%@",error);
}

//接收本地通知
- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
    NSLog(@"接收本地通知！");
    [BPush showLocalNotificationAtFront:notification identifierKey:nil];
}

- (BOOL)userHasRemoteNotificationsEnabled {
    UIApplication *application = [UIApplication sharedApplication];
    if ([[UIApplication sharedApplication] respondsToSelector:@selector(registerUserNotificationSettings:)]) {
        return application.currentUserNotificationSettings.types != UIUserNotificationTypeNone;
    } else {
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wdeprecated-declarations"
        return application.enabledRemoteNotificationTypes != UIRemoteNotificationTypeNone;
#pragma GCC diagnostic pop
    }
}

@end
