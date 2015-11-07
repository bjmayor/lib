//
//  HttpEngine+Account.m
//  DDDict
//
//  Created by Peter on 13-6-14.
//
//

#import "HttpEngine+Account.h"

@implementation HttpEngine (Account)
- (NSDictionary *)paramDevice
{
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:2];
    params[TAG_IDENTIFIER] = [UIDevice wifiMac];
    params[TAG_PLATFORM] = @"iOS";
    params[TAG_NAME] = [[UIDevice currentDevice] platform];
    return params;
}

- (void)autoLogin:(id<HaloHttpRequestDelegate>)delegate responseBlock:(ResponseBlock)responseBlock property:(NSInteger)property
{
    MyUserInformation *user = [MyUserInformation infoFromUserDefault];
    
    if ([user canLogin])
    {
        NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:2];
        params[TAG_USERNAME] = user.username;
        params[TAG_PWD] = user.password;
        
        HaloHttpRequest *request = [self makePostRequestByTag:EHttpAccountAutoLogin properties:PROP_NORMAL_NO_WAITDLG|PROP_LOGIN_REQUEST|property params:params];
        [self startHttpRequest:request delegate:delegate parseBlock:^id(HaloHttpRequest *r, id data, NSError *error) {
            r.delegate = nil;
            [self parseLoginUserInformation:data username:params[TAG_USERNAME] password:params[TAG_PWD]];
            return data[TAG_SID];
        } responseBlock:responseBlock];
    }
    else
    {
        NSDictionary *params = [self paramDevice];
        HaloHttpRequest *request = [self makePostRequestByTag:EHttpAccountGuest properties:PROP_NORMAL_NO_WAITDLG|PROP_LOGIN_REQUEST|property params:params];
        [self startHttpRequest:request delegate:delegate parseBlock:^id(HaloHttpRequest *r, id data, NSError *error) {
            r.delegate = nil;
            return data[TAG_SID];
        } responseBlock:responseBlock];
    }
}

- (MyUserInformation *)parseLoginUserInformation:(NSDictionary *)data username:(NSString *)username password:(NSString *)password
{
    MyUserInformation *user = [[MyUserInformation alloc] init];
    user.verified = [data[TAG_VERIFY] intValue];
    user.uid = [data[TAG_UID] intValue];
    user.username = username;
    user.password = password;
    NSDictionary *userTag = data[TAG_USER];
    [user setProperties:userTag];
    [user saveToUserDefault];
    [self postNotification:NotificationLogined object:nil];
    return user;
}

- (void)login:(NSString *)email password:(NSString *)password delegate:(id<HaloHttpRequestDelegate>)delegate responseBlock:(ResponseBlock)responseBlock
{
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:2];
    params[TAG_USERNAME] = [email lowercaseString];
    params[TAG_PWD] = password;
    params[TAG_DEVICE] = [self paramDevice];

    HaloHttpRequest *request = [self makePostRequestByTag:EHttpAccountLogin properties:PROP_NORMAL|PROP_LOGIN_REQUEST params:params];
    [self startHttpRequest:request delegate:delegate parseBlock:^id(HaloHttpRequest *r, id data, NSError *error) {
        return [self parseLoginUserInformation:data username:params[TAG_USERNAME] password:params[TAG_PWD]];
    } responseBlock:responseBlock];
}

- (void)signUp:(NSString *)email password:(NSString *)password delegate:(id<HaloHttpRequestDelegate>)delegate responseBlock:(ResponseBlock)responseBlock
{
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:2];
    params[TAG_USERNAME] = [email lowercaseString];
    params[TAG_PWD] = password;
    params[TAG_DEVICE] = [self paramDevice];
    
    HaloHttpRequest *request = [self makePostRequestByTag:EHttpAccountRegister properties:PROP_NORMAL|PROP_LOGIN_REQUEST params:params];
    [self startHttpRequest:request delegate:delegate parseBlock:^id(HaloHttpRequest *r, id data, NSError *error) {
        return [self parseLoginUserInformation:data username:params[TAG_USERNAME] password:params[TAG_PWD]];
    } responseBlock:responseBlock];
}

- (void)setSignUpProfile:(NSString *)name avatarPath:(NSString *)avatarPath delegate:(id<HaloHttpRequestDelegate>)delegate responseBlock:(ResponseBlock)responseBlock
{
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:2];
    params[TAG_NAME] = name;
    
    HaloHttpRequest *request = [self makePostRequestByTag:EHttpAccountSetProfile properties:PROP_NORMAL|PROP_LOGIN_REQUEST params:nil];
    [request setPostFormData:params fileParamName:TAG_PICTURE filePath:avatarPath];
    [self startHttpRequest:request delegate:delegate parseBlock:^id(HaloHttpRequest *r, id data, NSError *error) {
        NSString *url = data[TAG_PICTURE];
        MyUserInformation *user = [MyUserInformation infoFromUserDefault];
        user.avatarURL = [NSURL URLWithString:url];
        user.name = name;
        [user saveToUserDefault];
        return user;
    } responseBlock:responseBlock];
}

- (void)loginByWeibo:(NSString *)weiboId accessToken:(NSString *)token delegate:(id<HaloHttpRequestDelegate>)delegate responseBlock:(ResponseBlock)responseBlock
{
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:2];
    params[TAG_WEIBO_ID] = weiboId;
    params[TAG_TOKEN] = token;
    params[TAG_DEVICE] = [self paramDevice];
    
    HaloHttpRequest *request = [self makePostRequestByTag:EHttpAccountLoginByWeibo properties:PROP_NORMAL|PROP_LOGIN_REQUEST params:params];
    [self startHttpRequest:request delegate:delegate parseBlock:^id(HaloHttpRequest *r, id data, NSError *error) {
        return [self parseLoginUserInformation:data username:params[TAG_WEIBO_ID] password:nil];
    } responseBlock:responseBlock];
}

- (void)resendVerifyEmail:(NSString *)email delegate:(id<HaloHttpRequestDelegate>)delegate responseBlock:(ResponseBlock)responseBlock
{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[TAG_EMAIL] = email;
    
    HaloHttpRequest *request = [self makePostRequestByTag:EHttpAccountSendVerifyEmail properties:PROP_NORMAL params:params];
    request.userInfo[HaloUserInfoKeySuccessInfo] = NSLocalizedStringFromTable(@"resend_email_done", @"Login", nil);
    [self startHttpRequest:request delegate:delegate parseBlock:nil responseBlock:responseBlock];
}

- (void)checkVerified:(id<HaloHttpRequestDelegate>)delegate responseBlock:(ResponseBlock)responseBlock
{    
    HaloHttpRequest *request = [self makeGetRequestByTag:EHttpAccountCheckVerified properties:PROP_NORMAL_NO_WAITDLG params:nil];
    [self startHttpRequest:request delegate:delegate parseBlock:^id(HaloHttpRequest *r, id data, NSError *error) {
        return data[TAG_VERIFY];
    } responseBlock:responseBlock];
}

- (void)getUser:(NSInteger)uid delegate:(id<HaloHttpRequestDelegate>)delegate responseBlock:(ResponseBlock)responseBlock
{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[TAG_UID] = @(uid);
    HaloHttpRequest *request = [self makeGetRequestByTag:EHttpAccountGetUser properties:PROP_NORMAL_NO_WAITDLG params:params];
    [self startHttpRequest:request delegate:delegate parseBlock:^id(HaloHttpRequest *r, id data, NSError *error) {
        UserInformation *user = [UserInformation infoFromJson:data];
        return user;
    } responseBlock:responseBlock];
}
@end
