//
//  HttpEngine+Book.h
//  DDDict
//
//  Created by Peter on 13-6-12.
//
//

#import "HttpEngine.h"

@interface HttpEngine (Book)
- (void)searchWord:(NSString *)key delegate:(id<HaloHttpRequestDelegate>)delegate responseBlock:(ResponseBlock)block;
- (void)getZhWordDetail:(NSInteger)wordId delegate:(id<HaloHttpRequestDelegate>)delegate responseBlock:(ResponseBlock)block;
- (void)getWordDetail:(NSInteger)wordId delegate:(id<HaloHttpRequestDelegate>)delegate responseBlock:(ResponseBlock)block;
- (void)getWordDetailByKey:(NSString *)word delegate:(id<HaloHttpRequestDelegate>)delegate responseBlock:(ResponseBlock)block;
- (void)sync:(id<HaloHttpRequestDelegate>)delegate responseBlock:(ResponseBlock)block;
- (void)queryBatch:(NSArray *)ids delegate:(id<HaloHttpRequestDelegate>)delegate responseBlock:(ResponseBlock)block;
- (void)getWordAllPhrase:(NSInteger)wordId delegate:(id<HaloHttpRequestDelegate>)delegate responseBlock:(ResponseBlock)block;
- (void)getWordAllSentence:(NSInteger)wordId delegate:(id<HaloHttpRequestDelegate>)delegate responseBlock:(ResponseBlock)block;
@end
