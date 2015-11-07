//
//  HttpEngine+Status.h
//  DDDict
//
//  Created by Peter on 13-7-9.
//
//

#import "HttpEngine.h"
#import "ListInfo.h"
@interface HttpEngine (Status)
- (void)createStatus:(NSArray *)words description:(NSString *)description image:(UIImage *)image delegate:(id<HaloHttpRequestDelegate>)delegate responseBlock:(ResponseBlock)block;
- (void)getTimeline:(TimeLineType)type objId:(NSInteger)objId listInfo:(ListInfo *)listInfo delegate:(id<HaloHttpRequestDelegate>)delegate responseBlock:(ResponseBlock)block;
- (void)likeStatus:(NSInteger)statusId like:(BOOL)like delegate:(id<HaloHttpRequestDelegate>)delegate responseBlock:(ResponseBlock)block;
- (void)commentStatus:(NSString*)text statusId:(NSInteger)statusId commentId:(NSInteger)commentId delegate:(id<HaloHttpRequestDelegate>)delegate responseBlock:(ResponseBlock)block;
- (void)reportStatus:(NSInteger)statusId delegate:(id<HaloHttpRequestDelegate>)delegate responseBlock:(ResponseBlock)block;
- (void)reportComment:(NSInteger)commentId delegate:(id<HaloHttpRequestDelegate>)delegate responseBlock:(ResponseBlock)block;
- (void)getLiked:(NSInteger)statusId listInfo:(ListInfo *)listInfo delayLoad:(BOOL)delay delegate:(id<HaloHttpRequestDelegate>)delegate responseBlock:(ResponseBlock)block;
- (void)getComment:(NSInteger)statusId listInfo:(ListInfo *)listInfo delegate:(id<HaloHttpRequestDelegate>)delegate responseBlock:(ResponseBlock)block;
- (void)deleteStatus:(NSInteger)statusId delegate:(id<HaloHttpRequestDelegate>)delegate responseBlock:(ResponseBlock)block;
- (void)deleteComment:(NSInteger)commentId delegate:(id<HaloHttpRequestDelegate>)delegate responseBlock:(ResponseBlock)block;
@end
