//
//  OS.m
//  Hello World
//
//  Created by  on 13-5-19.
//  Copyright (c) 2013年 __Company__. All rights reserved.
//

#import "OS.h"
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>

@implementation OS

+ (void)facetime:(NSString* )number
{
    [self facetime:number confirm:NO];
}

+ (void)facetime:(NSString*)number confirm:(BOOL)confirm
{
    NSString *dialString = [NSString stringWithFormat:@"facetime://%@",number];
    NSURL *url = [NSURL URLWithString:dialString];
    if ( confirm )
    {
        UIWebView *phoneCallWebView = [[UIWebView alloc] initWithFrame:CGRectZero];
        [phoneCallWebView loadRequest:[NSURLRequest requestWithURL:url]];
    }
    else
    {
        [[UIApplication sharedApplication] openURL: [NSURL URLWithString:dialString]];
    }
}

+ (void)call:(NSString* )phone confirm:(BOOL)confirm
{
	NSString *p = [phone unFormatNumber];
	DDLogVerbose(@"call:%@",p);
    if ( confirm )
    {
        NSURL *phoneURL = [NSURL URLWithString:[NSString stringWithFormat:@"tel:%@",p]];
        UIWebView *phoneCallWebView = [[UIWebView alloc] initWithFrame:CGRectZero];
        [phoneCallWebView loadRequest:[NSURLRequest requestWithURL:phoneURL]];
    }
    else
    {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"tel:%@",p]]];
    }
}

+ (void)call:(NSString*)phone
{
    [self call:phone confirm:YES];
}

+ (void)openMap:(NSString*)address
{
	address = [address stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	NSString *urlString = [NSString stringWithFormat:@"http://maps.google.com/maps?q=%@",address];
	[[UIApplication sharedApplication]  openURL:[NSURL URLWithString:urlString]];
}

+ (void)openSafari:(NSString* )url
{
	NSString *http = @"http://";
	if (url.length < http.length || ![[url substringToIndex:http.length] isEqualToString:http])
	{
		NSString *u = [NSString stringWithFormat:@"%@%@",http,url];
		[[UIApplication sharedApplication]  openURL:[NSURL URLWithString:[u trimSpaceAndReturn]]];
	}
	else
	{
		[[UIApplication sharedApplication]  openURL:[NSURL URLWithString:url]];
	}
}

+ (BOOL)ipodPlaying
{
	MPMusicPlayerController *controller = [MPMusicPlayerController iPodMusicPlayer];
	if(controller)
	{
        DDLogVerbose(@"MPMusicPlayerController: %d",[controller playbackState]);
		if ([controller playbackState] == MPMoviePlaybackStatePlaying)
        {
            return  YES;
        }
        return NO;
	}
	else
	{
		return NO;
	}
}

+ (void)resumeIPod
{
    [[AVAudioSession sharedInstance] setCategory: AVAudioSessionCategoryPlayback error: nil];
    UInt32 doSetProperty = 1;
    AudioSessionSetProperty (kAudioSessionProperty_OverrideCategoryMixWithOthers, sizeof(doSetProperty), &doSetProperty);
    [[AVAudioSession sharedInstance] setActive: YES error: nil];
}

+ (void)setSoundToSpeaker:(BOOL)speaker
{
    if (speaker)
    {
        UInt32 p = 1;
        AudioSessionSetProperty(kAudioSessionProperty_OverrideCategoryDefaultToSpeaker,sizeof(p), &p);
    }
    else
    {
        UInt32  p = kAudioSessionCategory_PlayAndRecord;
        AudioSessionSetProperty (kAudioSessionProperty_AudioCategory, sizeof (p), &p);
    }
}

+ (void)copyToPasteboard:(NSString *)text
{
    UIPasteboard *gpBoard = [UIPasteboard generalPasteboard];
    [gpBoard setValue:text forPasteboardType:@"public.utf8-plain-text"];
    [MBProgressHUD showInfoHUD:NSLocalizedStringFromTableInBundle(@"copied_to_paste",@"Global", [Halo bundle] ,nil) warning:NO showDelay:2];
}
@end
