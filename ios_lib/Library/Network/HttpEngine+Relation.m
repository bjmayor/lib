//
//  HttpEngine+Relation.m
//  DDDict
//
//  Created by Peter on 13-7-18.
//
//

#import "HttpEngine+Relation.h"
#import "ListInfo.h"
@implementation HttpEngine (Relation)
- (void)followUser:(NSInteger)uid follow:(BOOL)follow delegate:(id<HaloHttpRequestDelegate>)delegate responseBlock:(ResponseBlock)block
{
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:2];
    params[TAG_OBJ_UID] = @(uid);
    params[TAG_FOLLOW] = @(follow);
    
    HaloHttpRequest *request = [self makeGetRequestByTag:EHttpRelationFollow properties:PROP_NORMAL_NO_WAITDLG params:params];
    [self startHttpRequest:request delegate:delegate parseBlock:nil responseBlock:block];
}

- (void)getUserListByType:(UserListType)type uid:(NSInteger)uid listInfo:(ListInfo *)listInfo delegate:(id<HaloHttpRequestDelegate>)delegate responseBlock:(ResponseBlock)block
{
    NSMutableDictionary *params = [listInfo jsonDictionary];
    params[TAG_OBJ_UID] = @(uid);
    
    HttpRequestTag tag = EHttpRelationFollowers;
    if (type == EUserFriends)
    {
        tag = EHttpRelationFriends;
    }
    
    HaloHttpRequest *request = [self makeGetRequestByTag:tag properties:PROP_NORMAL_NO_WAITDLG|PROP_DELAY params:params];
    [self startHttpRequest:request delegate:delegate parseBlock:^id(HaloHttpRequest *r, id data, NSError *error) {
        NSMutableArray *result = [NSMutableArray array];
        for (NSDictionary *item in data)
        {
            UserInformation *user = [UserInformation infoFromJson:item];
            [result addObject:user];
        }
        return result;
    } responseBlock:block];
   
}
@end
