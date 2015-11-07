//
//  HaloHttpRequest.h
//
//  Created by Peter on 11-7-19.
//

#import <Foundation/Foundation.h>
#import "HaloHttpRequestDelegate.h"
#define HTTP_POST @"POST"
#define HTTP_GET @"GET"

#define KMaxLastHttpCount 20
#define KMaxLastFileHttpCount 50

static const int PROP_ENABLE_WAITDLG = 0x1;
static const int PROP_ENABLE_SUCCESS_NOTE = 0x2;
static const int PROP_ENABLE_ERR_NOTE = 0x4;
static const int PROP_DISABLE_BAR_STATUS = 0x8;
static const int PROP_SHOW_SUCCESS_ICON = 0x10;
static const int PROP_ENABLE_WAIT_TITLE = 0x20;
static const int PROP_ENABLE_WAIT = 0x40;
static const int PROP_DELAY = 0x80;
static const int PROP_ENABLE_FAILED_NOTE = 0x100;
static const int PROP_DISABLE_DISMISS_WAIT_DLG = 0x200;
static const int PROP_NORMAL = 0x1 | 0x2 | 0x4 | 0x100;
static const int PROP_NORMAL_NO_WAITDLG = 0x2 | 0x4 | 0x100;

#if NS_BLOCKS_AVAILABLE
typedef void (^HaloHttpBasicBlock)(HaloHttpRequest* request);
typedef void (^HaloHttpResponseBlock)(NSURLResponse * response);
typedef void (^HaloHttpProgressBlock)(unsigned long long offset, unsigned long long totalSize);
typedef void (^HaloHttpDataBlock)(NSData *data);
typedef void (^ResponseBlock)(id error, id data, id userInfo);
typedef id (^ParseBlock)(HaloHttpRequest *r, id data, NSError *error);
#endif
extern NSString *HaloUserInfoKeySuccessInfo;
extern NSString *HaloUserInfoKeyErrInfo;
extern NSString *HaloUserInfoKeyWaitInfo;
extern NSString *HaloUserInfoKeyFailedInfo;

typedef enum
{
    EHaloHttpStateNone = 0,
    EHaloHttpStateStart,
    EHaloHttpStateSend,
    EHaloHttpStateReceive,
    EHaloHttpStateFinished,
    EHaloHttpStateCanceled,
    EHaloHttpStateFailed,
}HaloHttpState;

@interface HaloHttpRequest : NSOperation

@property(nonatomic,strong)NSURL *url;
@property(nonatomic,strong)NSString *requestMethod;
@property(nonatomic,strong)NSData *postBody;
@property(nonatomic,strong)NSMutableData *receivedBody;
@property(nonatomic,strong)NSMutableDictionary *requestHeaders;
@property(nonatomic,strong)NSString *downloadPath;
//if set uploadFilePath, please do not set fileSize;
@property(nonatomic,strong)NSString *uploadFilePath;
@property(nonatomic)unsigned long long contentLength;
@property(nonatomic)unsigned long long fileOffset;
@property(nonatomic)unsigned long long fileSize;
@property(nonatomic,strong)NSMutableDictionary *userInfo;
@property(nonatomic,weak)id<HaloHttpRequestDelegate> delegate;
@property(nonatomic,readonly)HaloHttpState state;
@property(nonatomic)NSInteger properties;
@property(nonatomic,assign)NSInteger tag;
@property(nonatomic)NSTimeInterval timeout;


@property(nonatomic,copy)HaloHttpBasicBlock startedBlock;
@property(nonatomic,copy)HaloHttpBasicBlock completeBlock;
@property(nonatomic,copy)HaloHttpBasicBlock failureBlock;
@property(nonatomic,copy)HaloHttpProgressBlock progressBlock;
@property(nonatomic,copy)HaloHttpDataBlock dataReceivedBlock;
@property(nonatomic,copy)HaloHttpResponseBlock responseBlock;


+ (id)requestWithDelegate:(id)delegate tag:(NSInteger)tag properties:(NSInteger)properites;
+ (id)requestWithTag:(NSInteger)tag properties:(NSInteger)properites;
- (BOOL)supportProperty:(NSInteger)property;
- (void)addProperty:(NSInteger)property;
- (void)startAsynchronous;
- (void)setPostFormData:(NSDictionary *)formData fileParamName:(NSString *)fileParamName filePath:(NSString *)filePath;
+ (void)cancelRequest:(id)delegate;
+ (void)cancelRequestByTag:(NSInteger)tag;
- (void)disableProperty:(NSInteger)property;
+ (void)disableAllRequestProperty:(NSInteger)property;
+ (NSInteger)getMaxRequestQueueCount;
+ (void)setMaxRequestQueueCount:(NSInteger)count;
+ (void)cancelAllRequest;
+ (BOOL)isRequestExistByTag:(NSInteger)tag;



@end