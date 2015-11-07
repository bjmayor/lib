//
// REMailActivity.m
// REActivityViewController
//
// Copyright (c) 2013 Roman Efimov (https://github.com/romaonthego)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
//

#import "REMailActivity.h"
#import "REActivityView.h"
#import "REActivityDelegateObject.h"

@implementation REMailActivity

- (id)init
{
    self = [super initWithTitle:NSLocalizedStringFromTableInBundle(@"activity.Mail.title", @"REActivityViewController",[self bundle], @"Mail")
                          image:[HaloTheme imageNamed:@"REActivityViewController.bundle/Icon_Mail"]
                    actionBlock:nil];
    
    
    if (!self)
        return nil;
    
    __typeof(&*self) __weak weakSelf = self;
    self.actionBlock = ^(REActivity *activity, REActivityView *activityView) {
        NSDictionary *userInfo = weakSelf.userInfo ? weakSelf.userInfo : activityView.userInfo;
        NSString *subject = userInfo[REActivitySubject];
        NSString *text = userInfo[REActivityText];
        UIImage *image = userInfo[REActivityImage];
        NSURL *url = userInfo[REActivityURL];
    
        MFMailComposeViewController *mailComposeViewController = [[MFMailComposeViewController alloc] init];
        if (mailComposeViewController) {
            [REActivityDelegateObject sharedObject].controller = activityView.viewController;
            mailComposeViewController.mailComposeDelegate = [REActivityDelegateObject sharedObject];
            
            if (text && !url)
                [mailComposeViewController setMessageBody:text isHTML:YES];
            
            if (!text && url)
                [mailComposeViewController setMessageBody:url.absoluteString isHTML:YES];
            
            if (text && url)
                [mailComposeViewController setMessageBody:[NSString stringWithFormat:@"%@ %@", text, url.absoluteString] isHTML:YES];
            
            if (image)
                [mailComposeViewController addAttachmentData:UIImageJPEGRepresentation(image, 0.75f) mimeType:@"image/jpeg" fileName:@"photo.jpg"];
            
            if (subject)
                [mailComposeViewController setSubject:subject];
            
            [activityView.viewController presentViewController:mailComposeViewController animated:YES completion:nil];
        }
    };
    
    return self;
}

@end
