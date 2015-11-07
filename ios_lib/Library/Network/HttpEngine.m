//
//  HttpEngine.m
//  Hello World
//
//  Created by Peter on 13-5-21.
//  Copyright (c) 2013年 __Company__. All rights reserved.
//

#import "HttpEngine.h"
#import "Host.h"
#import "WordBasicInfo.h"
#import "HttpEngine+Account.h"
#import "Halo.h"

#define KAccount @"account"
#define KBook @"book"
#define KRelation @"relation"
#define KStatus @"status"
#define KComment @"comment"
#define Make_URL(Path,Query) [NSString stringWithFormat:fmt,Path,Query]

@interface HttpEngine()
@property (nonatomic,assign) NSInteger appVersion;
@property (nonatomic,strong) NSString *identifier;
@end
@implementation HttpEngine
SYNTHESIZE_ARC_SINGLETON_FOR_CLASS(HttpEngine)
- (NSString *)makeURL:(HttpRequestTag)tag
{
	NSString *fmt = [NSString stringWithFormat:@"http://%@/%%@/%%@",KHost];
	NSString *urlString = nil;
	switch (tag)
	{
        case EHttpAccountGuest:
            urlString = Make_URL(KAccount,@"guest");
            break;
        case EHttpAccountRegister:
            urlString = Make_URL(KAccount,@"register");
            break;
        case EHttpAccountSetProfile:
            urlString = Make_URL(KAccount,@"set-profile");
            break;
        case EHttpAccountLogin:
        case EHttpAccountAutoLogin:
            urlString = Make_URL(KAccount,@"login");
            break;
        case EHttpAccountLoginByWeibo:
            urlString = Make_URL(KAccount,@"login-by-weibo");
            break;
        case EHttpAccountCheckVerified:
            urlString = Make_URL(KAccount,@"check-verify");
            break;
        case EHttpAccountSendVerifyEmail:
            urlString = Make_URL(KAccount,@"send-verify");
            break;
        case EHttpAccountGetUser:
            urlString = Make_URL(KAccount,@"get-user");
            break;
            
            
        case EHttpWordSearch:
            urlString = Make_URL(KBook,@"query");
            break;
        case EHttpWordDetail:
            urlString = Make_URL(KBook,@"detail");
            break;
        case EHttpWordZhDetail:
            urlString = Make_URL(KBook, @"zh-detail");
            break;
        case EHttpWordDetailByKey:
            urlString = Make_URL(KBook,@"detail-by-key");
            break;
        case EHttpWordSync:
            urlString = Make_URL(KBook,@"sync");
            break;
        case EHttpWordAllPhrase:
            urlString = Make_URL(KBook,@"phrase");
            break;
        case EHttpWordAllSentence:
            urlString = Make_URL(KBook,@"sentence");
            break;
        case EhttpWordQueryBatch:
            urlString = Make_URL(KBook,@"query-batch");
            break;
            
        case EHttpRelationFollow:
            urlString = Make_URL(KRelation,@"follow");
            break;
        case EHttpRelationBlock:
            urlString = Make_URL(KRelation,@"block");
            break;
        case EHttpRelationFriends:
            urlString = Make_URL(KRelation,@"friends");
            break;
        case EHttpRelationFollowers:
            urlString = Make_URL(KRelation,@"followers");
            break;

            
        case EHttpStatusCreate:
            urlString = Make_URL(KStatus,@"create");
            break;
        case EHttpStatusDelete:
            urlString = Make_URL(KStatus,@"del");
            break;
        case EHttpStatusReport:
            urlString = Make_URL(KStatus,@"report");
            break;
        case EHttpStatusFriendsTimeline:
            urlString = Make_URL(KStatus,@"friends-timeline");
            break;
        case EHttpStatusNewTimeline:
            urlString = Make_URL(KStatus,@"new-timeline");
            break;
        case EHttpStatusHotTimeline:
            urlString = Make_URL(KStatus,@"hot-timeline");
            break;
        case EHttpStatusUserTimeline:
            urlString = Make_URL(KStatus,@"user-timeline");
            break;
        case EHttpStatusPraisedTimeline:
            urlString = Make_URL(KStatus,@"praised-timeline");
            break;

            
        case EHttpCommentCreate:
            urlString = Make_URL(KComment,@"create");
            break;
        case EHttpCommentDelete:
            urlString = Make_URL(KComment,@"del");
            break;
        case EHttpCommentReport:
            urlString = Make_URL(KComment,@"report");
            break;
        case EHttpCommentGetComment:
            urlString = Make_URL(KComment,@"get-comment");
            break;
        case EHttpCommentPraise:
            urlString = Make_URL(KComment,@"praise");
            break;
        case EHttpCommentGetPraise:
            urlString = Make_URL(KComment,@"get-praise");
            break;

        default:
            assert(false);
            break;
	}
	return urlString;
}

- (id)init
{
    self = [super init];
    if (self)
    {
        self.appVersion = [Halo plistVersionInteger];
        self.identifier = [UIDevice deviceId];
        self.sid = [[HaloUserDefault sharedInstance] stringForKey:SETTING_KEY_SID defaultValue:nil];
        if (self.sid.length == 0)
        {
            [self autoLogin:nil responseBlock:^(id error, id data, id userInfo) {
                if (error == nil)
                {
                    self.sid = data;
                    [[HaloUserDefault sharedInstance] setString:self.sid forKey:SETTING_KEY_SID];
                }
            } property:0];
        }
    }
    return self;
}

- (HaloHttpRequest *)makeGetRequestByTag:(HttpRequestTag)tag properties:(NSInteger)properties params:(NSDictionary *)params
{
    HaloHttpRequest *request = [HaloHttpRequest requestWithTag:tag properties:properties];
    request.requestMethod = HTTP_GET;
    NSMutableString *url = [NSMutableString stringWithString:[self makeURL:tag]];
    if (params.allKeys.count > 0)
    {
        [url appendString:@"?"];
        for (NSString *key in params.allKeys)
        {
            NSValue *v = [params objectForKey:key];
            if ([v isKindOfClass:[NSString class]])
            {
                v = (NSValue *)[((NSString *)v) URLEncodedString];
            }
            [url appendFormat:@"%@=%@&",key,v];
        }
    }
    
    request.url = [NSURL URLWithString:url];
    return request;
}

- (HaloHttpRequest *)makePostRequestByTag:(HttpRequestTag)tag properties:(NSInteger)properties params:(NSDictionary *)params
{
    HaloHttpRequest *request = [HaloHttpRequest requestWithTag:tag properties:properties];
    request.requestMethod = HTTP_POST;
    NSMutableString *url = [NSMutableString stringWithString:[self makeURL:tag]];
    
    NSMutableDictionary *info = [NSMutableDictionary dictionary];
    info[@"identifier"] = self.identifier;
    info[@"os_version"] = [[UIDevice currentDevice] systemVersion];
    info[@"app_verion"] = @(self.appVersion);
    info[@"lang"] = [Halo currentLanguage];
    
    NSMutableDictionary *paramObj = [NSMutableDictionary dictionary];
    paramObj[@"info"] = info;
    paramObj[@"data"] = params;
    
    
    if ([NSJSONSerialization isValidJSONObject:params])
    {
        NSData* jsonData =[NSJSONSerialization dataWithJSONObject:params options:NSJSONWritingPrettyPrinted error:nil];
        request.postBody = jsonData;
    }
    request.url = [NSURL URLWithString:url];
    return request;
}

- (void)startHttpRequest:(HaloHttpRequest *)request delegate:(id<HaloHttpRequestDelegate>)delegate parseBlock:(ParseBlock)parseBlock responseBlock:(ResponseBlock)block
{
    if (self.sid.length == 0 && ![request supportProperty:PROP_LOGIN_REQUEST])
    {
        [self autoLogin:delegate responseBlock:^(id error, id data, id userInfo) {
            if (error == nil)
            {
                self.sid = data;
                [[HaloUserDefault sharedInstance] setString:self.sid forKey:SETTING_KEY_SID];            
                [self startHttpRequest:request delegate:delegate parseBlock:parseBlock responseBlock:block];
            }
            else
            {
                block(error,nil,nil);
            }
        } property:request.properties];
        return;
    }
    //custom http header
    NSString *info = [NSString stringWithFormat:@"'identifier':'%@','os_version':'%@','app_version':'%d','platform':'iPhone'",self.identifier,[[UIDevice currentDevice] systemVersion],self.appVersion];
    request.requestHeaders[@"info"] = info;
    request.requestHeaders[@"sid"] = self.sid;
    request.delegate = delegate;
    
    [request setCompleteBlock:^(HaloHttpRequest *r) {
        NSError *error;
        NSDictionary *jsonData;
        if (r.receivedBody)
        {
            jsonData = [NSJSONSerialization JSONObjectWithData:r.receivedBody options:kNilOptions error:&error];
        }
        
        if (jsonData)
        {
            NSInteger code = [jsonData[@"code"] intValue];
            if (code == 0)
            {
                dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
                dispatch_async(queue,^{
                    id parsedData = nil;
                    if (parseBlock)
                    {
                        id d = jsonData[@"data"];
                        if ([d isKindOfClass:[NSArray class]])
                        {
                            if ([d count] == 0)
                            {
                                d = nil;
                            }
                        }
                        parsedData = parseBlock(r, d, error);
                    }
                    dispatch_async(dispatch_get_main_queue(),^{
                        if (block)
                        {
                            block(error, parsedData, r.userInfo);
                        }                        
                    });
                });
            }
            else
            {
                if (error == nil)
                {
                    NSString *desc = jsonData[@"data"][@"desc"];
                    if (desc.length == 0)
                    {
                        NSString *key = jsonData[@"data"][@"key"];
                        if (key.length > 0)
                        {
                            desc = [NSString stringWithFormat:@"%@ (Server)",key];
                        }
                    }
                    error = [NSError errorWithDomain:KNilString code:code userInfo:[NSDictionary dictionaryWithObject:desc ? desc : KNilString forKey:NSLocalizedDescriptionKey]];
                }
                if ([error localizedDescription])
                {
                    r.userInfo[HaloUserInfoKeyErrInfo] = [error localizedDescription];
                }
                [r.delegate requestFailed:r error:error];
                if (block)
                {
                    block(error,nil,nil);
                }
            }
        }
        else
        {
#ifdef __DEBUG__
            NSString *err = [error localizedDescription];
            if (r.receivedBody)
            {
                err = [NSString stringWithFormat:@"%s",r.receivedBody.bytes];
            }
            else
            {
                err = @"No Data";
            }
            error = [NSError errorWithDomain:KNilString code:-1000 userInfo:[NSDictionary dictionaryWithObject:err forKey:NSLocalizedDescriptionKey]];
            
#else
            NSString * err = [NSString stringWithFormat:NSLocalizedStringFromTableInBundle(@"warning_http_err",@"Network",[Halo bundle],nil), -1000];
            error = [NSError errorWithDomain:KNilString code:-1000 userInfo:[NSDictionary dictionaryWithObject:err forKey:NSLocalizedDescriptionKey]];
#endif
            
            r.userInfo[HaloUserInfoKeyErrInfo] = [error localizedDescription];
//            [delegate requestFailed:r error:error];
            if (block)
            {
                block (error, nil, nil);
            }
        }
        [r.delegate requestFinished:r error:error];
    }];
    
    [request setFailureBlock:^(HaloHttpRequest *r) {
#ifdef __DEBUG__
        NSString *desc = [r.userInfo objectForKey:HaloUserInfoKeyFailedInfo];
        r.userInfo[HaloUserInfoKeyErrInfo] = @"haha";
        desc = [NSString stringWithFormat:@"Request %@:\n %@",[r.url absoluteString],desc];
        DDLogError(@"%@",desc);
#else
        NSString *desc = [NSString stringWithFormat:NSLocalizedStringFromTableInBundle(@"warning_http_err",@"Network",[Halo bundle],nil), -1000];
        DDLogError(@"%@",desc);
#endif
        NSError *error = [NSError errorWithDomain:KNilString code:-1000 userInfo:[NSDictionary dictionaryWithObject:desc ? desc : KNilString forKey:NSLocalizedDescriptionKey]];
        [r.delegate requestFailed:r error:error];
        if (block)
        {
            block (error, nil,nil);
        }
    }];
    
    [request setStartedBlock:^(HaloHttpRequest *r) {
        [r.delegate requestStarted:r];
    }];
    
    __weak HaloHttpRequest *my = request;
    [request setProgressBlock:^(unsigned long long offset, unsigned long long totalSize) {
        HaloHttpRequest *strongSelf = my;
        if ( [delegate respondsToSelector:@selector(setProgress:size:total:)])
        {
            [delegate setProgress:strongSelf size:offset total:totalSize];
        }
    }];
    
    [request startAsynchronous];
}

- (void)postNotification:(NSString *)name object:(id)object
{
    dispatch_block_t block = ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:name object:object];
    };
    
    if ([NSThread isMainThread])
    {
        block();
    }
    else
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            block();
        });
    }
}
@end
