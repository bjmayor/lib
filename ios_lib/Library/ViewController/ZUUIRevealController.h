/* 
 
 Copyright (c) 2011, Philip Kluz (Philip.Kluz@zuui.org)
 All rights reserved.
 
 Redistribution and use in source and binary forms, with or without
 modification, are permitted provided that the following conditions are met:
 
 * Redistributions of source code must retain the above copyright
 notice, this list of conditions and the following disclaimer.
 
 * Redistributions in binary form must reproduce the above copyright
 notice, this list of conditions and the following disclaimer in the
 documentation and/or other materials provided with the distribution.
 
 * Neither the name of Philip Kluz, 'zuui.org' nor the names of its contributors may 
 be used to endorse or promote products derived from this software 
 without specific prior written permission.
 
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
 ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 DISCLAIMED. IN NO EVENT SHALL PHILIP KLUZ BE LIABLE FOR ANY DIRECT, 
 INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
 ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 
 */

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "HaloUIViewController.h"
typedef enum
{
	FrontViewPositionOrigin,
	FrontViewPositionRight,
    FrontViewPositionLeft,
} FrontViewPosition;

typedef enum
{
    None,
    Left,
    Right,
}Direction;

#define REVEAL_RIGHT_EDGE 50.f

@protocol ZUUIRevealControllerDelegate;

@interface ZUUIRevealController : HaloUIViewController <UITableViewDelegate>

// Public Properties:
@property (strong, nonatomic) UINavigationController *frontViewController;
@property (strong, nonatomic) HaloUIViewController *leftRearViewController;
@property (strong, nonatomic) HaloUIViewController *rightRearViewController;

@property (assign, nonatomic) FrontViewPosition currentFrontViewPosition;
@property (weak, nonatomic) id<ZUUIRevealControllerDelegate> delegate;

//default 280
@property (assign, nonatomic) CGFloat rearViewRevealWidth;
//default 1.0
@property (nonatomic, assign) CGFloat scaleRate;
//default 0.0
@property (nonatomic, assign) CGFloat coverOpactity;

// Public Methods:
- (id)initWithFrontViewController:(UINavigationController *)aFrontViewController leftRearViewController:(UIViewController *)leftViewController rightRearViewController:(UIViewController *)rightViewController;

- (void)revealGesture:(UIPanGestureRecognizer *)recognizer;
- (void)revealToggle:(Direction)direction;
- (void)leftRevealToggle:(id)sender;
- (void)rightRevealToggle:(id)sender;

- (void)setFrontViewController:(UINavigationController *)frontViewController;
- (void)setFrontViewController:(UIViewController *)frontViewController animated:(BOOL)animated;
- (void)setFrontViewController:(UIViewController *)frontViewController animated:(BOOL)animated couldChangeOpen:(BOOL)couldChangeOpen;
@end


// ZUUIRevealControllerDelegate Protocol.
@protocol ZUUIRevealControllerDelegate<NSObject>//需要子类实现

@optional

- (BOOL)revealController:(ZUUIRevealController *)revealController shouldRevealRearViewController:(UIViewController *)rearViewController;

- (BOOL)revealController:(ZUUIRevealController *)revealController shouldHideRearViewController:(UIViewController *)rearViewController;

/* 
 * IMPORTANT: It is not guaranteed that 'didReveal...' will be called after 'willReveal...'. The user 
 * might not have panned far enough for a reveal to be triggered! Thus 'didHide...' will be called!
 */
- (void)revealController:(ZUUIRevealController *)revealController willRevealRearViewController:(UIViewController *)rearViewController;

- (void)revealController:(ZUUIRevealController *)revealController didRevealRearViewController:(UIViewController *)rearViewController;

- (void)revealController:(ZUUIRevealController *)revealController willHideRearViewController:(UIViewController *)rearViewController;

- (void)revealController:(ZUUIRevealController *)revealController didHideRearViewController:(UIViewController *)rearViewController;

#pragma mark - New in 0.9.5

- (void)revealController:(ZUUIRevealController *)revealController willSwapToFrontViewController:(UIViewController *)frontViewController;
- (void)revealController:(ZUUIRevealController *)revealController didSwapToFrontViewController:(UIViewController *)frontViewController;

@end