//
//  HttpEngine.h
//  Hello World
//
//  Created by Peter on 13-5-21.
//  Copyright (c) 2013年 __Company__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HaloHttpRequest.h"
#import "JsonTag.h"
typedef enum {
    EHttpAccountGuest,
    EHttpAccountRegister,
    EHttpAccountSetProfile,
    EHttpAccountLogin,
    EHttpAccountAutoLogin,
    EHttpAccountLoginByWeibo,
    EHttpAccountCheckVerified,
    EHttpAccountSendVerifyEmail,
    EHttpAccountNotification,
    EHttpAccountHeart,
    EHttpAccountGetUser,
    
    EHttpWordSearch,
    EHttpWordDetail,
    EHttpWordZhDetail,
    EHttpWordDetailByKey,
    EHttpWordSync,
    EHttpWordAllPhrase,
    EHttpWordAllSentence,
    EhttpWordQueryBatch,
    
    EHttpRelationFollow,
    EHttpRelationBlock,
    EHttpRelationFriends,
    EHttpRelationFollowers,
    
    EHttpStatusCreate,
    EHttpStatusDelete,
    EHttpStatusReport,
    EHttpStatusFriendsTimeline,
    EHttpStatusNewTimeline,
    EHttpStatusHotTimeline,
    EHttpStatusUserTimeline,
    EHttpStatusPraisedTimeline,
    
    
    EHttpCommentCreate,
    EHttpCommentDelete,
    EHttpCommentReport,
    EHttpCommentGetComment,
    EHttpCommentPraise,
    EHttpCommentGetPraise

}HttpRequestTag;

static const int PROP_LOGIN_REQUEST = 0x400;

@interface HttpEngine : NSObject
SYNTHESIZE_SINGLETON_FOR_CLASS_HEADER(HttpEngine)
@property (nonatomic,strong) NSString *sid;
- (HaloHttpRequest *)makeGetRequestByTag:(HttpRequestTag)tag properties:(NSInteger)properties params:(NSDictionary *)params;
- (HaloHttpRequest *)makePostRequestByTag:(HttpRequestTag)tag properties:(NSInteger)properties params:(NSDictionary *)params;
- (void)startHttpRequest:(HaloHttpRequest *)request delegate:(id<HaloHttpRequestDelegate>)delegate parseBlock:(ParseBlock)parseBlock responseBlock:(ResponseBlock)block;
- (void)postNotification:(NSString *)name object:(id)object;
@end
