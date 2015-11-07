//
//  MemoryInfoOverView.m
//  YContact
//
//  Created by li peiqiang on 12-8-23.
//  Copyright (c) 2012年 . All rights reserved.
//
#import <mach/task_info.h>
#import <mach/mach.h>
#import <mach/mach_host.h>
#import "MemoryInfoOverView.h"
NSString* NIStringFromBytes(unsigned long long bytes) {
    static const void* sOrdersOfMagnitude[] = {
        @"bytes", @"KB", @"MB", @"GB"
    };
    
    // Determine what magnitude the number of bytes is by shifting off 10 bits at a time
    // (equivalent to dividing by 1024).
    NSInteger magnitude = 0;
    unsigned long long highbits = bytes;
    unsigned long long inverseBits = ~((unsigned long long)0x3FF);
    while ((highbits & inverseBits)
           && magnitude + 1 < (sizeof(sOrdersOfMagnitude) / sizeof(void *))) {
        // Shift off an order of magnitude.
        highbits >>= 10;
        magnitude++;
    }
    
    if (magnitude > 0) {
        unsigned long long dividend = 1024 << (magnitude - 1) * 10;
        double result = ((double)bytes / (double)(dividend));
        return [NSString stringWithFormat:@"%.2f %@",
                result,
                sOrdersOfMagnitude[magnitude]];
        
    } else {
        // We don't need to bother with dividing bytes.
        return [NSString stringWithFormat:@"%lld %@", bytes, sOrdersOfMagnitude[magnitude]];
    }
}

@implementation MemoryInfoOverView
@synthesize label;
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.hidden = NO;
        self.backgroundColor = [UIColor blackColor];
        UILabel* tmpLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        tmpLabel.font = [UIFont systemFontOfSize:11.0f];
        tmpLabel.backgroundColor = [UIColor blackColor];
        tmpLabel.textColor = [UIColor whiteColor];
        [self addSubview:tmpLabel];
        self.label = tmpLabel;
        
        [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(update) userInfo:nil repeats:YES];
    }
    return self;
}
- (void)layoutSubviews
{
    [super layoutSubviews];
    [self.label sizeToFit];
    self.label.left = (self.width - self.label.width)/2;
    self.label.top = (self.height - self.label.height)/2;
}
+ (MemoryInfoOverView*)overView
{
    CGRect statusBarFrame = [UIApplication sharedApplication].statusBarFrame;
    MemoryInfoOverView*  overView = [[MemoryInfoOverView alloc] initWithFrame:CGRectInset(statusBarFrame, 100, 0)];
    overView.windowLevel = UIWindowLevelStatusBar + 1;
    overView.userInteractionEnabled = NO;
    return overView;
}

- (void)update
{
    NSString* freeMem = [NSString stringWithFormat:@"free mem %@",NIStringFromBytes((unsigned long long)[MemoryInfoOverView get_free_memory])];
    self.label.text = [NSString stringWithFormat:@"%@ total %@",
                        NIStringFromBytes([self bytesOfUsedMemory]),freeMem];
    
    
    [self setNeedsLayout];
}

- (unsigned long long)bytesOfUsedMemory
{
    struct task_basic_info info;
    mach_msg_type_number_t size = sizeof(info);
    kern_return_t kerr = task_info( mach_task_self(), TASK_BASIC_INFO, (task_info_t)&info, &size );
    if ( kerr == KERN_SUCCESS ) {
        return info.resident_size;
    }
    else {
        return 0;
    }
}

+ (unsigned int)get_free_memory
{
    mach_port_t host_port;
    mach_msg_type_number_t host_size;
    vm_size_t pagesize;
    
    host_port = mach_host_self();
    host_size = sizeof(vm_statistics_data_t) / sizeof(integer_t);
    host_page_size(host_port, &pagesize);
    
    vm_statistics_data_t vm_stat;
    
    if (host_statistics(host_port, HOST_VM_INFO, (host_info_t)&vm_stat, &host_size) != KERN_SUCCESS)
    {
        DDLogWarn(@"Failed to fetch vm statistics");
        return 0;
    }
    
    /* Stats in bytes */
    natural_t mem_free = vm_stat.free_count * pagesize;
    return mem_free;
}

@end
