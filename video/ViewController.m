//
//  ViewController.m
//  video
//
//  Created by Qeebu on 13-12-16.
//  Copyright (c) 2013年 Qeebu. All rights reserved.
//

#import "ViewController.h"
#import "Vitamio.h"
#import "PlayerViewController2.h"

@interface ViewController ()

@end

@implementation ViewController

static NSString *sMediaURLs[] = {
    @"http://www.qeebu.com/newe/Public/Attachment/99/52958fdb45565.mp4"
};

static int sCurrPlayIdx;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Buttons Action

-(IBAction)playButtonAction:(id)sender
{
	sCurrPlayIdx = 0;
	PlayerViewController2 *playerCtrl;
	playerCtrl = [[PlayerViewController2 alloc] initWithNibName:@"PlayerViewController2" bundle:nil];
	playerCtrl.delegate = self;
	[self presentModalViewController:playerCtrl animated:YES];
}


#pragma mark - PlayerControllerDelegate

- (NSURL *)playCtrlGetCurrMediaTitle:(NSString **)title lastPlayPos:(long *)lastPlayPos
{
//	int num = sizeof(sMediaURLs) / sizeof(sMediaURLs[0]);
//	sCurrPlayIdx = (sCurrPlayIdx + num) % num;
//	NSString *v = sMediaURLs[sCurrPlayIdx];
//	return [NSURL URLWithString:[v stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    return [NSURL URLWithString:[@"http://www.qeebu.com/newe/Public/Attachment/99/52958fdb45565.mp4" stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
}

- (NSURL *)playCtrlGetNextMediaTitle:(NSString **)title lastPlayPos:(long *)lastPlayPos
{
//	int num = sizeof(sMediaURLs) / sizeof(sMediaURLs[0]);
//	sCurrPlayIdx = (sCurrPlayIdx + num + 1) % num;
//	NSString *v = sMediaURLs[sCurrPlayIdx];
//	return [NSURL URLWithString:[v stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
     return [NSURL URLWithString:[@"http://www.qeebu.com/newe/Public/Attachment/99/52958fdb45565.mp4" stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
}

- (NSURL *)playCtrlGetPrevMediaTitle:(NSString **)title lastPlayPos:(long *)lastPlayPos
{
//	int num = sizeof(sMediaURLs) / sizeof(sMediaURLs[0]);
//	sCurrPlayIdx = (sCurrPlayIdx + num - 1) % num;
//	NSString *v = sMediaURLs[sCurrPlayIdx];
//	return [NSURL URLWithString:[v stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
     return [NSURL URLWithString:[@"http://www.qeebu.com/newe/Public/Attachment/99/52958fdb45565.mp4" stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
}


@end
