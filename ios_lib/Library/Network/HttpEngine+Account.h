//
//  HttpEngine+Account.h
//  DDDict
//
//  Created by Peter on 13-6-14.
//
//

#import "HttpEngine.h"

@interface HttpEngine (Account)
- (void)autoLogin:(id<HaloHttpRequestDelegate>)delegate responseBlock:(ResponseBlock)responseBlock property:(NSInteger)property;
- (void)login:(NSString *)email password:(NSString *)password delegate:(id<HaloHttpRequestDelegate>)delegate responseBlock:(ResponseBlock)responseBlock;
- (void)signUp:(NSString *)email password:(NSString *)password delegate:(id<HaloHttpRequestDelegate>)delegate responseBlock:(ResponseBlock)responseBlock;
- (void)setSignUpProfile:(NSString *)name avatarPath:(NSString *)avatarPath delegate:(id<HaloHttpRequestDelegate>)delegate responseBlock:(ResponseBlock)responseBlock;
- (void)loginByWeibo:(NSString *)weiboId accessToken:(NSString *)token delegate:(id<HaloHttpRequestDelegate>)delegate responseBlock:(ResponseBlock)responseBlock;
- (void)resendVerifyEmail:(NSString *)email delegate:(id<HaloHttpRequestDelegate>)delegate responseBlock:(ResponseBlock)responseBlock;
- (void)checkVerified:(id<HaloHttpRequestDelegate>)delegate responseBlock:(ResponseBlock)responseBlock;
- (void)getUser:(NSInteger)uid delegate:(id<HaloHttpRequestDelegate>)delegate responseBlock:(ResponseBlock)responseBlock;
@end
