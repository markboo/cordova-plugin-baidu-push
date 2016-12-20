
#import <Cordova/CDV.h>
#import <CoreLocation/CoreLocation.h>

@interface BaiduPushPlugin : CDVPlugin

@property (nonatomic) CDVPluginResult *result;
@property (nonatomic, copy) NSString *callbackId;
@property (nonatomic, copy) NSString *appkey;
@property (nonatomic, strong) NSDictionary *notificationMessage;
@property (nonatomic, strong) NSMutableDictionary *handlerObj;

- (void)registerChannel:(CDVInvokedUrlCommand*)command;
- (void)notificationReceived:(NSString *) message;
- (void)notificationReceived;

/*!
 @method
 @abstract 绑定
 */
- (void) startWork:(CDVInvokedUrlCommand*)command;

/*!
 @method
 @abstract 解除绑定
 */
- (void) stopWork:(CDVInvokedUrlCommand*)command;

/*!
 @method
 @abstract 回复绑定
 */
- (void) resumeWork:(CDVInvokedUrlCommand*)command;

/*!
@method
@abstract 设置Tag
*/
- (void) setTags:(CDVInvokedUrlCommand*)command;

/*!
 @method
 @abstract 删除Tag
 */
- (void) delTags:(CDVInvokedUrlCommand*)command;

@end
