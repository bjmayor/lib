//
//  HaloHttpRequestDelegate.h
//
//  Created by Peter on 11-7-19.
//

#import <Foundation/Foundation.h>
@class HaloHttpRequest;
@protocol HaloHttpRequestDelegate<NSObject>

@optional
- (void)requestStarted:(HaloHttpRequest *)request;
- (void)requestFinished:(HaloHttpRequest *)request error:(NSError *)error;
- (void)requestFailed:(HaloHttpRequest *)request error:(NSError *)error;

@optional
- (void)setProgress:(HaloHttpRequest *)request size:(float)size total:(float)total;
- (void)setUILoadingProgress:(HaloHttpRequest *)request number:(NSInteger)number sum:(NSInteger)sum;
@end
