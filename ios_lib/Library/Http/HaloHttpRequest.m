//
//  HaloHttpRequest.m
//
//  Created by Peter on 11-7-19.
//

#import "HaloHttpRequest.h"
#import "DDLog.h"
#import "DDTTYLogger.h"
#import "HaloFileUtil.h"

static NSOperationQueue *__sharedQueue = nil;

static int __maxRequestCount = KMaxLastHttpCount;
// The thread all requests will run on
// Hangs around forever, but will be blocked unless there are requests underway
#define KFileWriteSize (5*1024)
#define KDefaultTimeOut 30


NSString *HaloUserInfoKeySuccessInfo = @"success";
NSString *HaloUserInfoKeyErrInfo = @"error";
NSString *HaloUserInfoKeyFailedInfo = @"failed";
NSString *HaloUserInfoKeyWaitInfo = @"wait";

@interface HaloHttpRequest()
{
    CFRunLoopSourceRef runLoopSource;
}

@property(nonatomic)BOOL complete;
@property(nonatomic)BOOL finished;
@property(nonatomic)BOOL cancelled;

@property (nonatomic,readwrite)HaloHttpState state;
@property (nonatomic,readwrite)NSInteger trafficLength;
@property (nonatomic,strong) NSFileHandle *fileHandle;
@property(nonatomic)unsigned long long netTraffic;
@property(nonatomic,strong)NSURLConnection *connection;
@property(nonatomic,strong)NSTimer *timer;
@property(nonatomic,strong)NSDate *httpStartTime;

- (void)enableTimer:(BOOL)enable;
- (void)releaseBlocksOnMainThread;
@end

@implementation HaloHttpRequest
void RunLoopSourcePerformRoutine (void *info);

- (void)enableTimer:(BOOL)enable
{
    [self.timer invalidate];

    if (enable)
    {
        self.timer = [NSTimer scheduledTimerWithTimeInterval:self.timeout target:self selector:@selector(httpTimeOut) userInfo:nil repeats:NO];
    }
    else
    {
        self.timer = nil;
    }
}


+ (void)initialize
{
    if (self == [HaloHttpRequest class])
    {
        __sharedQueue = [[NSOperationQueue alloc] init];
		[__sharedQueue setMaxConcurrentOperationCount:4];
    }
}

- (id)init
{
    self = [super init];
    if(self)
    {
        self.state = EHaloHttpStateNone;
        self.requestMethod = HTTP_GET;
        self.timeout = KDefaultTimeOut;
        self.delegate = nil;
        self.userInfo = [NSMutableDictionary dictionary];
    }
    return self;
}

- (NSMutableDictionary*)requestHeaders
{
    if (!_requestHeaders)
    {
        _requestHeaders = [[NSMutableDictionary alloc] initWithCapacity:2];
    }
    return _requestHeaders;
}

- (void)setUrlString:(NSString*)urlString;
{
    NSString *trimUrl = [urlString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    self.url = [NSURL URLWithString:trimUrl];
}

+ (id)requestWithDelegate:(id)delegate tag:(NSInteger)tag properties:(NSInteger)properites
{
    HaloHttpRequest *request = [[HaloHttpRequest alloc] init];
    request.delegate = delegate;
    request.tag = tag;
    request.properties = properites;
    return request;
}

+ (id)requestWithTag:(NSInteger)tag properties:(NSInteger)properites
{
    HaloHttpRequest *request = [[HaloHttpRequest alloc] init];
    request.tag = tag;
    request.properties = properites;
    return request;
}

- (void)doTttpTimeOut
{
    [self performSelectorOnMainThread:@selector(requestFailed)withObject:nil waitUntilDone:[NSThread isMainThread]];
}

- (void)httpTimeOut
{
    [self.userInfo setObject:NSLocalizedStringFromTableInBundle(@"warning_connect_time_out",@"Network",[Halo bundle],nil) forKey:HaloUserInfoKeyFailedInfo];
    if (self.failureBlock)
    {
        [self doTttpTimeOut];
    }
}

- (void)doRequestStarted
{
    [self performSelectorOnMainThread:@selector(requestStarted)withObject:nil waitUntilDone:NO];
}

- (void)startAsynchronous
{
    if (__sharedQueue.operationCount > __maxRequestCount)
    {
        DDLogWarn(@"requests are max clean all: %d",__sharedQueue.operationCount);
        [__sharedQueue cancelAllOperations];
    }
    [__sharedQueue addOperation:self];
    if (self.startedBlock)
    {
        [self doRequestStarted];    
    }
    DDLogInfo(@"sharedQueue operation count:%d", __sharedQueue.operationCount);

}

- (void)setPostFormData:(NSDictionary *)formData fileParamName:(NSString *)fileParamName filePath:(NSString *)filePath
{
    if (formData.allKeys.count > 0)
    {
        NSString *boundary = [[NSProcessInfo processInfo] globallyUniqueString];
        self.requestHeaders[@"Content-type"] = [NSString stringWithFormat:@"multipart/form-data, boundary=%@",boundary];
        NSString *boundarySeparator = [NSString stringWithFormat:@"--%@\r\n", boundary];
        
        NSMutableData *postBody = [NSMutableData data];
        NSMutableString *items = [NSMutableString string];
        for (NSString *key in formData.allKeys)
        {
            [items appendString:boundarySeparator];
            [items appendFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n",key];
            [items appendFormat:@"%@\r\n",formData[key]];
        }
        
        [postBody appendData:[items dataUsingEncoding:NSUTF8StringEncoding]];

        if (filePath.length > 0)
        {
            [postBody appendData:[boundarySeparator dataUsingEncoding:NSUTF8StringEncoding]];
            [postBody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"%@\"\r\n", fileParamName, [filePath lastPathComponent]]dataUsingEncoding:NSUTF8StringEncoding]];
            [postBody appendData:[[NSString stringWithFormat:@"Content-Type: %@\r\n\r\n",[HaloFileUtil mimeTypeForFileAtPath:filePath]] dataUsingEncoding:NSUTF8StringEncoding]];
            [postBody appendData:[NSData dataWithContentsOfFile:filePath]];
            [postBody appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
        }
        [postBody appendData:[[NSString stringWithFormat:@"--%@--\r\n",boundary]
                              dataUsingEncoding:NSUTF8StringEncoding]];
        
        [self setPostBody:postBody];
    }
}


- (void)doRequestFailed
{
    [self performSelectorOnMainThread:@selector(requestFailed)withObject:nil waitUntilDone:[NSThread isMainThread]];
}

void RunLoopSourcePerformRoutine (void *info)
{
    HaloHttpRequest *request = (__bridge HaloHttpRequest*)info;
    request.delegate = nil;
    request.finished = YES;
    request.cancelled = YES;
    [request enableTimer:NO];
    [request.connection cancel];
}

- (void)main
{
    if ([self isCancelled])
    {
        return;
    }
    self.state = EHaloHttpStateStart;
    if (self.downloadPath.length > 0)
    {
        self.fileHandle = [NSFileHandle fileHandleForWritingAtPath:self.downloadPath];
        if (self.fileOffset == 0)
        {
            [[NSFileManager defaultManager] removeItemAtPath:self.downloadPath error:nil];
            if([[NSFileManager defaultManager] createFileAtPath:self.downloadPath contents:nil attributes:nil])
            {
                DDLogInfo(@"create file:%@",self.downloadPath );
            }
            else
            {
                DDLogError(@"Error was code: %d - message: %s", errno, strerror(errno));
            }
            self.fileHandle = [NSFileHandle fileHandleForWritingAtPath:self.downloadPath];
        }
        
        self.fileOffset = [self.fileHandle seekToEndOfFile];
            //requestInfo.fileOffset = offset;
    }
    
    self.receivedBody =[NSMutableData data]; 
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:self.url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:self.timeout];
    [request setTimeoutInterval:self.timeout];
    [request setHTTPMethod:self.requestMethod];
    if (self.downloadPath.length > 0 && self.fileOffset > 0)
    {
        [request setValue:[NSString stringWithFormat:@"bytes=%lld-",self.fileOffset] forHTTPHeaderField:@"Range"];
    }
    
    
    if (self.downloadPath.length == 0)
    {
        DDLogInfo(@"\r=============Http Start==================\r%@\r",self.url);
        
        if (self.uploadFilePath.length>0)
        {
            [request setValue:[HaloFileUtil mimeTypeForFileAtPath:self.uploadFilePath] forHTTPHeaderField:@"content-type"];
            [request setValue:[NSString stringWithFormat:@"%lld",self.fileSize-self.fileOffset] forHTTPHeaderField:@"Content-length"];
            [request setHTTPBodyStream:[NSInputStream inputStreamWithFileAtPath:self.uploadFilePath]];
        }
        else
        {
            [request setHTTPBody:self.postBody];
            self.netTraffic += self.postBody.length;
        }
        if (self.requestHeaders.count > 0)
        {
            for (NSString *key in [self.requestHeaders allKeys])
            {
                [request setValue:[self.requestHeaders objectForKey:key] forHTTPHeaderField:key];
            }
        }
    }
    DDLogInfo(@"request url:%@",self.url);
    DDLogInfo(@"request header:%@",request.allHTTPHeaderFields);
    if (ddLogLevel > LOG_LEVEL_WARN)
    {
        NSMutableData *tmp = [NSMutableData dataWithData:self.postBody];
        int end = 0;
        [tmp appendBytes:&end length:1];
        DDLogInfo(@"request body:%s",[tmp bytes]);
    }
    
    NSURLConnection *c = [NSURLConnection connectionWithRequest:request delegate:self];
    self.connection = c;
    self.complete = NO;
    self.finished = NO;
    self.cancelled = NO;
    if ([self supportProperty:PROP_DELAY]) 
    {
        self.httpStartTime = [NSDate date];
    }

    [self enableTimer:YES];
    CFRunLoopSourceContext context = {
        0,                 // version
        (__bridge void*)self,              // info
        0,                 // retain
        0,                 // release
        0,                 // copyDescription
        0,                 // equal
        0,                 // hash
        0,                 // schedule
        0,                 // cancel
        &RunLoopSourcePerformRoutine // perform
    };
    runLoopSource = CFRunLoopSourceCreate(kCFAllocatorDefault, 0, &context);
    if (runLoopSource)
    {
        CFRunLoopAddSource(CFRunLoopGetCurrent(), runLoopSource, kCFRunLoopCommonModes);
    }

    while(!self.complete)
    {
//        DDLogInfo(@"http canceled:%d in thread %@", [self isCancelled],[NSThread currentThread]);
        if ([self isCancelled])
        {
            CFRunLoopSourceInvalidate(runLoopSource);
            self.delegate = nil;
           // [self.connection setDelegateQueue:nil];
            [self.connection cancel];
            [self doRequestFailed];
            break;
        }
        NSDate *date = [NSDate distantFuture];//[NSDate dateWithTimeIntervalSinceNow:([[NSDate date] timeIntervalSinceNow] + 1)];
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:date];
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{    
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    });
    
    self.connection = nil;
}

- (void)setUploadFilePath:(NSString *)path
{
    _uploadFilePath = path;
    self.fileSize = [HaloFileUtil fileSize:path];
}

- (BOOL)isCancelled
{
    return self.cancelled;
}

- (void)connection:(NSURLConnection *)theConnection didReceiveResponse:(NSURLResponse *)response
{
    self.state = EHaloHttpStateReceive;
    NSHTTPURLResponse  *httpResponse;

    httpResponse = (NSHTTPURLResponse *)response;
    assert( [httpResponse isKindOfClass:[NSHTTPURLResponse class]] );
    DDLogInfo(@"http response status code:%d\n",httpResponse.statusCode);
//    LoggerS([httpResponse allHeaderFields]);
    NSDictionary *dict = [httpResponse allHeaderFields];
	DDLogInfo(@"response header:%@",dict);
    NSInteger size = [[dict objectForKey:@"Content-Length"] intValue];
    self.netTraffic += size;
    self.contentLength = size;
    
    id trafficSzie = [dict objectForKey:@"Traffic-Length"];
    if ( trafficSzie != nil )
    {
        self.trafficLength = [trafficSzie intValue];
    }
    else
    {
        self.trafficLength = 0;
    }
    
    if ( self.responseBlock )
    {
        self.responseBlock(response);
    }
    
	if (self.downloadPath.length > 0 && (httpResponse.statusCode == 200 || httpResponse.statusCode == 206))
	{
		
        if (httpResponse.statusCode == 206)
        {
            if (self.fileOffset + size != self.fileSize)
            {
                DDLogError(@"http file range err!");
                [self.userInfo setObject:[NSString stringWithFormat:NSLocalizedStringFromTableInBundle(@"warning_http_err",@"Network",[Halo bundle],nil),httpResponse.statusCode] forKey:HaloUserInfoKeyFailedInfo];
                //[self performSelectorOnMainThread:@selector(requestFailed)withObject:nil waitUntilDone:[NSThread isMainThread]];
                [self doRequestFailed];
                self.cancelled = YES;
                [self.connection cancel];
                NSString *tmp = @"";
                [tmp writeToFile:self.downloadPath atomically:YES encoding:NSASCIIStringEncoding error:nil];
                return;
            }
        }   

		
		if (self.fileOffset!=0 && ![dict objectForKey:@"Content-Range"])
		{
			NSString *tmp = @"";
			[tmp writeToFile:self.downloadPath atomically:YES encoding:NSASCIIStringEncoding error:nil];
			self.fileHandle = [NSFileHandle fileHandleForUpdatingAtPath:self.downloadPath];
			[self.fileHandle seekToEndOfFile];
            self.fileOffset = 0;
		}
	}
    
    if( (httpResponse.statusCode / 100)!= 2 )
	{
        [self.userInfo setObject:[NSString stringWithFormat:NSLocalizedStringFromTableInBundle(@"warning_http_err",@"Network",[Halo bundle],nil),httpResponse.statusCode] forKey:HaloUserInfoKeyFailedInfo];
        //[self performSelectorOnMainThread:@selector(requestFailed)withObject:nil waitUntilDone:[NSThread isMainThread]];
        [self doRequestFailed];
	}
}

- (void)doSetProgress
{
    [self performSelectorOnMainThread:@selector(setProgress)withObject:nil waitUntilDone:[NSThread isMainThread]];
}

- (void)connection:(NSURLConnection *)theConnection didReceiveData:(NSData *)data
{
//    [self enableTimer:YES];
    if ([self isCancelled])
    {
        return;
    }
	[self.receivedBody appendData:data];
    
	if (self.downloadPath.length > 0)
	{
		if (self.receivedBody.length >= KFileWriteSize)
		{
			[self.fileHandle writeData:self.receivedBody];
            self.fileOffset += self.receivedBody.length;
                // DDLogInfo(@"didReceiveData: %d",self.lastBytesRead);
            //[self performSelectorOnMainThread:@selector(setProgress)withObject:nil waitUntilDone:[NSThread isMainThread]];
            [self doSetProgress];
			[self.receivedBody setLength:0];
		}
	}
    else
    {
        if ( self.progressBlock )
        {
            self.fileOffset = self.receivedBody.length;
            [self doSetProgress];
        }
    }
}

- (void)connection:(NSURLConnection *)connection didSendBodyData:(NSInteger)bytesWritten totalBytesWritten:(NSInteger)totalBytesWritten totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite
{
    if ([self isCancelled])
    {
        return;
    }
    self.state = EHaloHttpStateSend;
    if (self.uploadFilePath.length > 0)
    {
        self.fileOffset = totalBytesWritten;
//        DDLogInfo(@"didSendBodyData:%d,%d,%lld", bytesWritten,totalBytesWritten,self.fileOffset);
 //      [self performSelectorOnMainThread:@selector(setProgress)withObject:nil waitUntilDone:[NSThread isMainThread]];
        [self doSetProgress];
    }
}

- (void)connection:(NSURLConnection *)theConnection didFailWithError:(NSError *)error
{
    [self enableTimer:NO];
    if ([self isCancelled])
    {
        return;
    }
    self.state = EHaloHttpStateFailed;
    CFRunLoopSourceInvalidate(runLoopSource);
	DDLogError(@"didFailWithError:\r%@\r%@",self.url,[error description]);
//    if (error.code == -1001 || error.code == -1009)
    {
        if ([self supportProperty:PROP_ENABLE_FAILED_NOTE])
        {
            if (error.code == -1009)
            {
                [self.userInfo setObject:NSLocalizedStringFromTableInBundle(@"warning_no_internet", @"Network",[Halo bundle],nil) forKey:HaloUserInfoKeyFailedInfo];
            }
            else
            {
                [self.userInfo setObject:[error localizedDescription] forKey:HaloUserInfoKeyFailedInfo];
            }
        }
    }
    self.complete = YES;
    self.finished = NO;
    self.receivedBody = nil;
	self.fileHandle = nil;
    if (self.failureBlock)
    {
        [self doRequestFailed];
    }
}

- (NSInputStream *)connection:(NSURLConnection *)connection needNewBodyStream:(NSURLRequest *)request
{
    [NSThread sleepForTimeInterval: 2];
    
    NSInputStream* fileStream = [NSInputStream inputStreamWithFileAtPath: self.uploadFilePath];
    
    if (fileStream == nil)
    {
        DDLogInfo(@"NSURLConnection was asked to retransmit a new body stream for a request. Returning nil will cancel the connection.");
    }
    
    return fileStream;
}

- (void)doRequestFinished
{
    dispatch_async( dispatch_get_main_queue(), ^{
        if (!self.cancelled)
        {
            [self requestFinished];    
        }
    });
    //        [self performSelectorOnMainThread:@selector(requestFinished)withObject:nil waitUntilDone:[NSThread isMainThread]];

}

- (void)connectionDidFinishLoading:(NSURLConnection *)theConnection
{
    [self enableTimer:NO];
    if ([self isCancelled])
    {
        return;
    }
    
    CFRunLoopSourceInvalidate(runLoopSource);
    self.complete = YES;
    self.finished = YES;
    

#warning maybe need block
    if (self.downloadPath.length == 0)
	{
        NSMutableData *tmp = [NSMutableData dataWithData:self.receivedBody];
        int end = 0;
        [tmp appendBytes:&end length:1];
        DDLogInfo(@"\r%@\r%s\r=============Http End==================",self.url,[tmp bytes]);
    }


    if (self.downloadPath.length > 0)
    {
        if (self.receivedBody.length > 0)
        {
            [self.fileHandle writeData:self.receivedBody];
            self.fileOffset += self.receivedBody.length;
            //[self performSelectorOnMainThread:@selector(setProgress)withObject:nil waitUntilDone:[NSThread isMainThread]];
            [self doSetProgress];
            [self.receivedBody setLength:0];
        }
        self.fileHandle = nil;
    }
    
    if ([self supportProperty:PROP_DELAY]) 
    {
        NSDate *now = [NSDate date];
        if ([now timeIntervalSinceDate:self.httpStartTime] < 1)
        {
            [NSThread sleepForTimeInterval:1.0f];
        }
    }
    if (self.cancelled)
    {
        return;
    }
    DDLogInfo(@"%@", [NSThread currentThread]);     
    if ( self.completeBlock || self.dataReceivedBlock)
    {
        [self doRequestFinished];
    }
    self.state = EHaloHttpStateFinished;
}

- (BOOL)supportProperty:(NSInteger)property
{
	return (self.properties & property)> 0;
}

- (void)addProperty:(NSInteger)property
{
    self.properties = self.properties|property;
}

#pragma mark -
#pragma mark main thread operation
- (void)requestStarted
{

    if (self.startedBlock)
    {
        self.startedBlock(self);
    }

}

- (void)requestFailed
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];

    if (self.failureBlock)
    {
        self.failureBlock(self);
    }


    if (![self supportProperty:PROP_ENABLE_FAILED_NOTE]) 
    {
        [self.userInfo removeObjectForKey:HaloUserInfoKeyFailedInfo];
        [self.userInfo removeObjectForKey:HaloUserInfoKeyErrInfo];
    }
    [self releaseBlocksOnMainThread];
    [self cancel];
}

- (void)requestFinished
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
//    [[self cancelledLock] lock];
    

    if (self.dataReceivedBlock)
    {
        self.dataReceivedBlock(self.receivedBody);
    }
    
    if (self.completeBlock)
    {
        self.completeBlock(self);
    }


    [self releaseBlocksOnMainThread];
}

- (void)setProgress
{
    if ([self isCancelled])
    {
        return;
    }
    NSInteger total = self.trafficLength;
    if ( total == 0 )
    {
        total = (self.fileSize == 0?self.contentLength:self.fileSize);
    }

    if (self.progressBlock)
    {
        self.progressBlock(self.fileOffset,total);
    }

}

+ (void)cancelRequest:(id)delegate
{
    DDLogInfo(@"request count: %d", __sharedQueue.operationCount);
    if (__sharedQueue.operations.count > 0 && delegate!=nil)
    {
        for (NSInteger i = __sharedQueue.operationCount - 1; i>=0 ;i--)
        {
            HaloHttpRequest *request = [__sharedQueue.operations objectAtIndex:i];
            if (request.delegate == delegate)
            {
                DDLogInfo(@"cancel request: %@", [[delegate class] description]);
                [request cancel];
                DDLogInfo(@"request count: %d,%d", __sharedQueue.operationCount,i);
            }
        }
    }
}

+ (void)cancelRequestByTag:(NSInteger)tag
{
    for (NSInteger i = __sharedQueue.operationCount - 1; i>=0 ;i--)
    {
        HaloHttpRequest *request = [__sharedQueue.operations objectAtIndex:i];
        if (request.tag == tag)
        {
            DDLogInfo(@"cancel request by tag: %d", tag);
            request.delegate = nil;
            [request cancel];
            DDLogInfo(@"request count: %d,%d", __sharedQueue.operationCount,i);
        }
    }
}

+ (void)disableAllRequestProperty:(NSInteger)property
{
    for (NSInteger i = __sharedQueue.operationCount - 1; i>=0 ;i--)
    {
        HaloHttpRequest *request = [__sharedQueue.operations objectAtIndex:i];
        [request disableProperty:property];
    }
}

- (void)disableProperty:(NSInteger)property
{
    self.properties = self.properties & (~property);
}

+ (NSInteger)getMaxRequestQueueCount
{
    return __maxRequestCount;
}

+ (void)setMaxRequestQueueCount:(NSInteger)count
{
    __maxRequestCount = count;
}

+ (void)cancelAllRequest
{
    [__sharedQueue cancelAllOperations];
}

+ (BOOL)isRequestExistByTag:(NSInteger)tag
{
    for (HaloHttpRequest *request in __sharedQueue.operations)
    {
        if (request.tag == tag)
        {
            return YES;
        }
    }
    return NO;
}

- (void)releaseBlocksOnMainThread
{
//    dispatch_async(dispatch_get_main_queue(), ^{
//        self.completionBlock = nil;
//        self.failureBlock = nil;
//        self.startedBlock = nil;
//        self.dataReceivedBlock = nil;
//        self.responseBlock = nil;
//        self.progressBlock = nil;
//    });
}


- (void)cancel
{
    [self releaseBlocksOnMainThread];
    if (self.cancelled)
    {
        return;
    }
    if (runLoopSource) 
    {
        CFRunLoopSourceSignal(runLoopSource);
        CFRunLoopWakeUp(CFRunLoopGetCurrent());
    }
    self.cancelled = YES;
    self.state = EHaloHttpStateCanceled;
}

- (void)dealloc
{
    [self enableTimer:NO];
    if (self.cancelled)
    {
        DDLogInfo(@"http canceled dealloc");
    }
    if (runLoopSource)
    {
        CFRunLoopRemoveSource(CFRunLoopGetCurrent(), runLoopSource, kCFRunLoopCommonModes);
        CFRelease(runLoopSource);
    }    
    

    [self releaseBlocksOnMainThread];

}

@end