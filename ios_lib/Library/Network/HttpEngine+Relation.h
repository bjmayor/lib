//
//  HttpEngine+Relation.h
//  DDDict
//
//  Created by Peter on 13-7-18.
//
//

#import "HttpEngine.h"
@class ListInfo;
@interface HttpEngine (Relation)
- (void)followUser:(NSInteger)uid follow:(BOOL)follow delegate:(id<HaloHttpRequestDelegate>)delegate responseBlock:(ResponseBlock)block;
- (void)getUserListByType:(UserListType)type uid:(NSInteger)uid listInfo:(ListInfo *)listInfo delegate:(id<HaloHttpRequestDelegate>)delegate responseBlock:(ResponseBlock)block;

@end
