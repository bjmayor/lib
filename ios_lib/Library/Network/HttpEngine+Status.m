//
//  HttpEngine+Status.m
//  DDDict
//
//  Created by Peter on 13-7-9.
//
//

#import "HttpEngine+Status.h"
#import "StatusInfo.h"
#import "HaloFileUtil.h"
#import "UserInformation.h"
#import "CommentInfo.h"

@implementation HttpEngine (Status)
- (void)createStatus:(NSArray *)words description:(NSString *)description image:(UIImage *)image delegate:(id<HaloHttpRequestDelegate>)delegate responseBlock:(ResponseBlock)block
{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    if (description.length > 0)
    {
        params[TAG_TEXT] = description;
    }
    if (words.count > 0)
    {
        NSString *json = [words componentsJoinedByString:@"\",\""];
        params[TAG_KEYWORDS] = [NSString stringWithFormat:@"[\"%@\"]",json];
    }
    HaloHttpRequest *request = [self makePostRequestByTag:EHttpStatusCreate properties:PROP_NORMAL params:params];
    NSString *path = [HaloFileUtil fileWithUploadPath:@"word.jpg"];
    [UIImageJPEGRepresentation(image, 0.7) writeToFile:path atomically:YES];
    [request setPostFormData:params fileParamName:TAG_PICTURE filePath:path];
    
    [self startHttpRequest:request delegate:delegate parseBlock:nil responseBlock:block];
}

- (void)getTimeline:(TimeLineType)type objId:(NSInteger)objId listInfo:(ListInfo *)listInfo delegate:(id<HaloHttpRequestDelegate>)delegate responseBlock:(ResponseBlock)block
{
    NSMutableDictionary *params = [listInfo jsonDictionary];
    if (objId > 0)
    {
        params[TAG_OBJ_UID] = @(objId);
    }
    
    HttpRequestTag tag;
    switch (type)
    {
        case ETimeLineFriends:
            tag = EHttpStatusFriendsTimeline;
            break;
        case ETimeLineHot:
            tag = EHttpStatusHotTimeline;
            break;
        case ETimeLineUser:
            tag = EHttpStatusUserTimeline;
            break;
        case ETimeLineLiked:
            tag = EHttpStatusPraisedTimeline;
            break;
        default:
            tag = EHttpStatusNewTimeline;
            break;
    }
    
    HaloHttpRequest *request = [self makeGetRequestByTag:tag properties:PROP_NORMAL_NO_WAITDLG|PROP_DELAY params:params];

    [self startHttpRequest:request delegate:delegate parseBlock:^id(HaloHttpRequest *r, id data, NSError *error) {
        NSMutableArray *result = [NSMutableArray arrayWithCapacity:[data count]];
        for (NSDictionary *item in data)
        {
            StatusInfo *info = [StatusInfo infoFromJson:item];
            [result addObject:info];
        }
        return result;
    } responseBlock:block];
}

- (void)likeStatus:(NSInteger)statusId like:(BOOL)like delegate:(id<HaloHttpRequestDelegate>)delegate responseBlock:(ResponseBlock)block
{
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:2];
    params[TAG_ID] = @(statusId);
    params[TAG_PRAISE] = @(like);
    
    HaloHttpRequest *request = [self makeGetRequestByTag:EHttpCommentPraise properties:PROP_NORMAL_NO_WAITDLG params:params];
    [self startHttpRequest:request delegate:delegate parseBlock:nil responseBlock:block];
}

- (void)commentStatus:(NSString*)text statusId:(NSInteger)statusId commentId:(NSInteger)commentId delegate:(id<HaloHttpRequestDelegate>)delegate responseBlock:(ResponseBlock)block
{
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:2];
    params[TAG_STATUS_ID] = @(statusId);
    params[TAG_TEXT] = text;
    if (commentId)
    {
        params[TAG_COMMENT_ID] = @(commentId);
    }
    
    HaloHttpRequest *request = [self makeGetRequestByTag:EHttpCommentCreate properties:PROP_NORMAL params:params];
    [self startHttpRequest:request delegate:delegate parseBlock:nil responseBlock:block];
}

- (void)reportStatus:(NSInteger)statusId delegate:(id<HaloHttpRequestDelegate>)delegate responseBlock:(ResponseBlock)block
{
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:2];
    params[TAG_ID] = @(statusId);
    
    HaloHttpRequest *request = [self makeGetRequestByTag:EHttpStatusReport properties:PROP_NORMAL params:params];
    request.userInfo[HaloUserInfoKeySuccessInfo] = NSLocalizedString(@"report_done", nil);
    [self startHttpRequest:request delegate:delegate parseBlock:nil responseBlock:block];
}

- (void)reportComment:(NSInteger)commentId delegate:(id<HaloHttpRequestDelegate>)delegate responseBlock:(ResponseBlock)block
{
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:2];
    params[TAG_ID] = @(commentId);
    HaloHttpRequest *request = [self makeGetRequestByTag:EHttpCommentReport properties:PROP_NORMAL params:params];
    request.userInfo[HaloUserInfoKeySuccessInfo] = NSLocalizedString(@"report_done", nil);
    [self startHttpRequest:request delegate:delegate parseBlock:nil responseBlock:block];
}

- (void)getLiked:(NSInteger)statusId listInfo:(ListInfo *)listInfo delayLoad:(BOOL)delay delegate:(id<HaloHttpRequestDelegate>)delegate responseBlock:(ResponseBlock)block
{
    NSMutableDictionary *params = [listInfo jsonDictionary];
    params[TAG_ID] = @(statusId);
    HaloHttpRequest *request = [self makeGetRequestByTag:EHttpCommentGetPraise properties:delay ? PROP_NORMAL_NO_WAITDLG|PROP_DELAY : PROP_NORMAL_NO_WAITDLG params:params];
    [self startHttpRequest:request delegate:delegate parseBlock:^id(HaloHttpRequest *r, id data, NSError *error) {
        NSMutableArray *result = [NSMutableArray array];
        for (NSDictionary *item in data)
        {
            UserInformation *user = [UserInformation infoFromJson:item[TAG_USER]];
            [result addObject:user];
        }
        return result;
    } responseBlock:block];

}

- (void)getComment:(NSInteger)statusId listInfo:(ListInfo *)listInfo delegate:(id<HaloHttpRequestDelegate>)delegate responseBlock:(ResponseBlock)block
{
    NSMutableDictionary *params = [listInfo jsonDictionary];
    params[TAG_ID] = @(statusId);
    HaloHttpRequest *request = [self makeGetRequestByTag:EHttpCommentGetComment properties:PROP_NORMAL_NO_WAITDLG params:params];
    [self startHttpRequest:request delegate:delegate parseBlock:^id(HaloHttpRequest *r, id data, NSError *error) {
        NSMutableArray *result = [NSMutableArray array];
        for(NSDictionary *item in data)
        {
            CommentInfo *info = [CommentInfo infoFromJson:item];
            [result addObject:info];
        }
        return result;
    } responseBlock:block];
}

- (void)deleteStatus:(NSInteger)statusId delegate:(id<HaloHttpRequestDelegate>)delegate responseBlock:(ResponseBlock)block
{
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:2];
    params[TAG_ID] = @(statusId);
    HaloHttpRequest *request = [self makeGetRequestByTag:EHttpStatusDelete properties:PROP_NORMAL params:params];
    [self startHttpRequest:request delegate:delegate parseBlock:nil responseBlock:block];
}

- (void)deleteComment:(NSInteger)commentId delegate:(id<HaloHttpRequestDelegate>)delegate responseBlock:(ResponseBlock)block
{
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:2];
    params[TAG_ID] = @(commentId);
    HaloHttpRequest *request = [self makeGetRequestByTag:EHttpCommentDelete properties:PROP_NORMAL params:params];
    [self startHttpRequest:request delegate:delegate parseBlock:nil responseBlock:block];
}
@end
