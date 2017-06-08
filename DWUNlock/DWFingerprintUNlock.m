//
//  DWFingerprintUNlock.m
//  DWUNlock
//
//  Created by dwang_sui on 2016/10/23.
//  Copyright © 2016年 dwang. All rights reserved.
//

#import "DWFingerprintUNlock.h"

@implementation DWFingerprintUNlock

#pragma mark ---指纹解锁
NSString *errMsg;
+ (void)dw_initWithFingerprintUNlockPromptMsg:(NSString *)promptMsg cancelMsg:(NSString *)cancelMsg otherMsg:(NSString *)otherMsg enabled:(BOOL)enabled otherClick:(void(^)(NSString *otherClick))otherClick  success:(void(^)(BOOL success))success error:(void(^)(NSError *error, NSString *errorMsg))error {
    //初始化上下文对象
    LAContext* context = [[LAContext alloc] init];
    context.localizedFallbackTitle = !otherMsg?@"":otherMsg;
    if ([[[UIDevice currentDevice]systemVersion]integerValue] >= 10)context.localizedCancelTitle = cancelMsg;
    //错误对象
    NSInteger APolicy = [[[UIDevice currentDevice]systemVersion]integerValue]<9?LAPolicyDeviceOwnerAuthenticationWithBiometrics:LAPolicyDeviceOwnerAuthentication;
    NSInteger Policy = enabled?LAPolicyDeviceOwnerAuthenticationWithBiometrics:LAPolicyDeviceOwnerAuthentication;
    //首先使用canEvaluatePolicy 判断设备支持状态
    if ([self dw_validationWhetherToSupport]) {
        //支持指纹验证
        [context evaluatePolicy:Policy localizedReason:promptMsg reply:^(BOOL succe, NSError *err) {
            if (succe) {
                dispatch_sync(dispatch_get_main_queue(), ^{
                    success(succe);
                });
                return ;
            }else {
                dispatch_sync(dispatch_get_main_queue(), ^{
                    switch (err.code) {
                        case LAErrorAuthenticationFailed:
                        {
                                errMsg = @"身份验证不成功,因为用户未能提供有效身份证件--->Authentication was not successful, because user failed to provide valid credentials";
                        }
                            break;
                        case LAErrorUserCancel:
                        {
                                errMsg = @"身份验证被用户取消--->Authentication was canceled by user(e.g. tapped Cancel button)";
                        }
                            break;
                        case LAErrorUserFallback:
                        {
                                errMsg = @"认证被取消了,因为用户利用回退按钮(选择其它认证方式)--->Authentication was canceled, because the user tapped the fallback button(Enter Password)";
                        }
                            break;
                        case LAErrorSystemCancel:
                        {
                            errMsg = @"身份验证被系统取消了--->Authentication was canceled by system(e.g. another application went to foreground)";
                        }
                            break;
                        case LAErrorPasscodeNotSet:
                        {
                            errMsg = @"身份验证无法启动,因为密码没有设置在设备上--->Authentication could not start, because passcode is not set on the device";
                        }
                            break;
                        case LAErrorTouchIDNotAvailable:
                        {
                            errMsg = @"身份验证无法启动,因为触摸ID不可用在设备上--->Authentication could not start, because Touch ID is not available on the device";
                        }
                            break;
                        case LAErrorTouchIDNotEnrolled:
                        {
                            errMsg = @"身份验证无法启动,因为没有登记的手指触摸Touch ID--->Authentication could not start, because Touch ID has no enrolled fingers";
                        }
                            break;
                        default:
                            otherClick(@"未知情况");
                                if (enabled) {
                                    [context evaluatePolicy:APolicy localizedReason:promptMsg reply:^(BOOL success, NSError * _Nullable error) {}];
                                }
                        break;
                    }
                    error(err, errMsg);
                });
               
            }
        }];
        
    }else {
        NSError *err = [NSError errorWithDomain:@"此设备不支持Touch ID" code:-10001 userInfo:nil];
        error(err, [NSString stringWithFormat:@"此设备不支持Touch ID--->设备操作系统:%@---设备系统版本号:%@--->设备型号:%@", [[UIDevice currentDevice] systemVersion], [[UIDevice currentDevice] systemName], [DWiPhoneType dw_iPhoneType]]);
    }
}


+ (BOOL)dw_validationWhetherToSupport {
    LAContext* context = [[LAContext alloc] init];
    NSInteger APolicy = [[[UIDevice currentDevice]systemVersion]integerValue]<9? LAPolicyDeviceOwnerAuthenticationWithBiometrics:LAPolicyDeviceOwnerAuthenticationWithBiometrics;
    return [context canEvaluatePolicy:APolicy error:nil];
}

@end
