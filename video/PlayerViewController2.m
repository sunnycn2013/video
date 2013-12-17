//
//  PlayerViewController2.m
//  video
//
//  Created by Qeebu on 13-12-17.
//  Copyright (c) 2013年 Qeebu. All rights reserved.
//

#import "PlayerViewController2.h"
#import "Utilities.h"

@interface PlayerViewController2 (){
    VMediaPlayer       *mMPayer;
    long               mDuration;
    long               mCurPostion;
    NSTimer            *mSyncSeekTimer;
    UIView* view;

}

@property (nonatomic, assign) IBOutlet UIButton *startPause;
@property (nonatomic, assign) IBOutlet UIButton *prevBtn;
@property (nonatomic, assign) IBOutlet UIButton *nextBtn;
@property (nonatomic, assign) IBOutlet UIButton *modeBtn;
@property (nonatomic, assign) IBOutlet UIButton *reset;
@property (nonatomic, assign) IBOutlet UISlider *progressSld;
@property (nonatomic, assign) IBOutlet UILabel  *curPosLbl;
@property (nonatomic, assign) IBOutlet UILabel  *durationLbl;
@property (nonatomic, assign) IBOutlet UILabel  *bubbleMsgLbl;
@property (nonatomic, assign) IBOutlet UILabel  *downloadRate;
@property (nonatomic, assign) IBOutlet UIView  	*activityCarrier;

@property (nonatomic, copy)   NSURL *videoURL;
@property (nonatomic, retain) UIActivityIndicatorView *activityView;

@end

@implementation PlayerViewController2
#pragma mark - Life Cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
	self.view.bounds = [[UIScreen mainScreen] bounds];
	self.activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:
                         UIActivityIndicatorViewStyleWhiteLarge];
    self.activityView.center = CGPointMake(-380, 300);
	[self.activityCarrier addSubview:self.activityView];
    
    self.view.backgroundColor = [UIColor blackColor];
	if (!mMPayer) {
		mMPayer = [VMediaPlayer sharedInstance];
        self.view.frame = CGRectMake(0, 0, 768, 1024);
		[mMPayer setupPlayerWithCarrierView:self.view withDelegate:self];
        
		[self setupObservers];
	}
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	[[UIApplication sharedApplication] setStatusBarHidden:YES];
	[[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
	[self becomeFirstResponder];
    
	[self currButtonAction:nil];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
	[[UIApplication sharedApplication] setStatusBarHidden:NO];
	[[UIApplication sharedApplication] endReceivingRemoteControlEvents];
    [self resignFirstResponder];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)dealloc
{
	
	[mMPayer unSetupPlayer];
}

- (BOOL)shouldAutorotate
{
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
	return UIInterfaceOrientationMaskAll;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}


#pragma mark - Respond to the Remote Control Events

- (BOOL)canBecomeFirstResponder
{
	return YES;
}

- (void)remoteControlReceivedWithEvent:(UIEvent *)event
{
	switch (event.subtype) {
		case UIEventSubtypeRemoteControlTogglePlayPause:
			if ([mMPayer isPlaying]) {
				[mMPayer pause];
			} else {
				[mMPayer start];
			}
			break;
		case UIEventSubtypeRemoteControlPlay:
			[mMPayer start];
			break;
		case UIEventSubtypeRemoteControlPause:
			[mMPayer pause];
			break;
		case UIEventSubtypeRemoteControlPreviousTrack:
			[self prevButtonAction:nil];
			break;
		case UIEventSubtypeRemoteControlNextTrack:
			[self nextButtonAction:nil];
			break;
		default:
			break;
	}
}

- (void)applicationDidEnterForeground:(NSNotification *)notification
{
    if (![mMPayer isPlaying]) {
		[mMPayer start];
		[self.startPause setTitle:@"Pause" forState:UIControlStateNormal];
	}
	[mMPayer setVideoShown:YES];
}

- (void)applicationDidEnterBackground:(NSNotification *)notification
{
    if ([mMPayer isPlaying]) {
		[mMPayer setVideoShown:NO];
    }
}


#pragma mark - VMediaPlayerDelegate Implement

#pragma mark VMediaPlayerDelegate Implement / Required

- (void)mediaPlayer:(VMediaPlayer *)player didPrepared:(id)arg
{
	[player setVideoFillMode:VMVideoFillModeFit];
    
	mDuration = [player getDuration];
    [player start];
    
	[self setBtnEnableStatus:YES];
	[self stopActivity];
    mSyncSeekTimer = [NSTimer scheduledTimerWithTimeInterval:1.0/3
                                                      target:self
                                                    selector:@selector(syncUIStatus)
                                                    userInfo:nil
                                                     repeats:YES];
}

- (void)mediaPlayer:(VMediaPlayer *)player playbackComplete:(id)arg
{
	[self goBackButtonAction:nil];
}

- (void)mediaPlayer:(VMediaPlayer *)player error:(id)arg
{
	NSLog(@"NAL 1RRE &&&& VMediaPlayer Error: %@", arg);
	[self stopActivity];
	[self showVideoLoadingError];
	[self setBtnEnableStatus:YES];
}

#pragma mark VMediaPlayerDelegate Implement / Optional

- (void)mediaPlayer:(VMediaPlayer *)player setupManagerPreference:(id)arg
{
    //	player.decodingSchemeHint = VMDecodingSchemeQuickTime;
}

- (void)mediaPlayer:(VMediaPlayer *)player setupPlayerPreference:(id)arg
{
	// Set buffer size, default is 1024KB(1*1024*1024).
    //	[player setBufferSize:2*1024*1024];
	[player setBufferSize:12*1024];
    //	[player setAdaptiveStream:YES];
}

- (void)mediaPlayer:(VMediaPlayer *)player bufferingStart:(id)arg
{
	if (![Utilities isLocalMedia:self.videoURL]) {
		[player pause];
		[self.startPause setTitle:@"Start" forState:UIControlStateNormal];
		[self startActivityWithMsg:@"Buffering... 0%"];
	}
}

- (void)mediaPlayer:(VMediaPlayer *)player bufferingUpdate:(id)arg
{
	if (!self.bubbleMsgLbl.hidden) {
		self.bubbleMsgLbl.text = [NSString stringWithFormat:@"Buffering... %d%%",
								  [((NSNumber *)arg) intValue]];
	}
}

- (void)mediaPlayer:(VMediaPlayer *)player bufferingEnd:(id)arg
{
	if (![Utilities isLocalMedia:self.videoURL]) {
		[player start];
		[self.startPause setTitle:@"Pause" forState:UIControlStateNormal];
		[self stopActivity];
	}
}

- (void)mediaPlayer:(VMediaPlayer *)player downloadRate:(id)arg
{
	if (![Utilities isLocalMedia:self.videoURL]) {
		self.downloadRate.text = [NSString stringWithFormat:@"%dKB/s", [arg intValue]];
	} else {
		self.downloadRate.text = nil;
	}
}


#pragma mark - Convention Methods

#define TEST_Common					1
#define TEST_setOptionsWithKeys		0
#define TEST_setDataSegmentsSource	0

-(void)quicklyPlayMovie:(NSURL*)fileURL title:(NSString*)title seekToPos:(long)pos
{
	[UIApplication sharedApplication].idleTimerDisabled = YES;
	[self setBtnEnableStatus:NO];
    
#if TEST_Common // Test Common
	NSString *abs = [fileURL absoluteString];
	if ([abs rangeOfString:@"://"].length == 0) {
		NSString *docDir = [NSString stringWithFormat:@"%@/Documents", NSHomeDirectory()];
		NSString *videoUrl = [NSString stringWithFormat:@"%@/%@", docDir, abs];
		self.videoURL = [NSURL fileURLWithPath:videoUrl];
	} else {
		self.videoURL = fileURL;
	}
    [mMPayer setDataSource:self.videoURL header:nil];
#elif TEST_setOptionsWithKeys // Test setOptionsWithKeys:withValues:
	self.videoURL = [NSURL URLWithString:@"http://www.qeebu.com/newe/Public/Attachment/99/52958fdb45565.mp4"]; // This is a live stream.
	NSMutableArray *keys = [NSMutableArray arrayWithCapacity:0];
	NSMutableArray *vals = [NSMutableArray arrayWithCapacity:0];
	keys[0] = @"-rtmp_live";
	vals[0] = @"-1";
    [mMPayer setDataSource:self.videoURL header:nil];
	[mMPayer setOptionsWithKeys:keys withValues:vals];
#elif TEST_setDataSegmentsSource // Test setDataSegmentsSource:fileList:
	NSMutableArray *list = [NSMutableArray arrayWithCapacity:0];
	[list addObject:@"http://www.qeebu.com/newe/Public/Attachment/99/52958fdb45565.mp4"];
	
    [mMPayer setDataSegmentsSource:nil fileList:list];
#endif
    
    [mMPayer prepareAsync];
	[self startActivityWithMsg:@"Loading..."];
}

-(void)quicklyReplayMovie:(NSURL*)fileURL title:(NSString*)title seekToPos:(long)pos
{
    [self quicklyStopMovie];
    [self quicklyPlayMovie:fileURL title:title seekToPos:pos];
}

-(void)quicklyStopMovie
{
	[mMPayer reset];
	[mSyncSeekTimer invalidate];
	mSyncSeekTimer = nil;
	[self stopActivity];
	self.curPosLbl.text = @"00:00:00";
	self.durationLbl.text = @"00:00:00";
	self.downloadRate.text = nil;
	self.progressSld.value = 0.0;
	[self setBtnEnableStatus:YES];
	[UIApplication sharedApplication].idleTimerDisabled = NO;
}


#pragma mark - UI Actions

#define DELEGATE_IS_READY(x) (self.delegate && [self.delegate respondsToSelector:@selector(x)])

-(IBAction)goBackButtonAction:(id)sender
{
	[self quicklyStopMovie];
	[self dismissModalViewControllerAnimated:YES];
}

-(IBAction)startPauseButtonAction:(id)sender
{
	BOOL isPlaying = [mMPayer isPlaying];
	if (isPlaying) {
		[mMPayer pause];
		//[self.startPause setTitle:@"Start" forState:UIControlStateNormal];
        [self.startPause setImage:[UIImage imageNamed:@"pause.png"] forState:UIControlStateNormal];
	} else {
		[mMPayer start];
		//[self.startPause setTitle:@"Pause" forState:UIControlStateNormal];
        [self.startPause setImage:[UIImage imageNamed:@"start.png"] forState:UIControlStateNormal];
	}
}

-(void)currButtonAction:(id)sender
{
	NSURL *url = nil;
	NSString *title = nil;
	long lastPos = 0;
	if (DELEGATE_IS_READY(playCtrlGetPrevMediaTitle:lastPlayPos:)) {
		url = [self.delegate playCtrlGetCurrMediaTitle:&title lastPlayPos:&lastPos];
	}
	if (url) {
		[self quicklyPlayMovie:url title:title seekToPos:lastPos];
	} else {
		NSLog(@"WARN: No previous media url found!");
	}
}

-(IBAction)prevButtonAction:(id)sender
{
	NSURL *url = nil;
	NSString *title = nil;
	long lastPos = 0;
	if (DELEGATE_IS_READY(playCtrlGetPrevMediaTitle:lastPlayPos:)) {
		url = [self.delegate playCtrlGetPrevMediaTitle:&title lastPlayPos:&lastPos];
	}
	if (url) {
		[self quicklyReplayMovie:url title:title seekToPos:lastPos];
	} else {
		NSLog(@"WARN: No previous media url found!");
	}
}

-(IBAction)nextButtonAction:(id)sender
{
	NSURL *url = nil;
	NSString *title = nil;
	long lastPos = 0;
	if (DELEGATE_IS_READY(playCtrlGetPrevMediaTitle:lastPlayPos:)) {
		url = [self.delegate playCtrlGetNextMediaTitle:&title lastPlayPos:&lastPos];
	}
	if (url) {
		[self quicklyReplayMovie:url title:title seekToPos:lastPos];
	} else {
		NSLog(@"WARN: No previous media url found!");
	}
}

-(IBAction)switchVideoViewModeButtonAction:(id)sender
{
	static emVMVideoFillMode modes[] = {
		VMVideoFillModeFit,
		VMVideoFillMode100,
		VMVideoFillModeCrop,
		VMVideoFillModeStretch,
	};
	static int curModeIdx = 0;
    
	curModeIdx = (curModeIdx + 1) % (int)(sizeof(modes)/sizeof(modes[0]));
	[mMPayer setVideoFillMode:modes[curModeIdx]];
}

-(IBAction)resetButtonAction:(id)sender
{
	[self quicklyStopMovie];
}

-(IBAction)dragProgressSliderAction:(id)sender
{
	UISlider *sld = (UISlider *)sender;
	[mMPayer seekTo:(long)(sld.value * mDuration)];
}


#pragma mark - Sync UI Status

-(void)syncUIStatus
{
	mCurPostion  = [mMPayer getCurrentPosition];
	[self.progressSld setValue:(float)mCurPostion/mDuration];
	self.curPosLbl.text = [Utilities timeToHumanString:mCurPostion];
	self.durationLbl.text = [Utilities timeToHumanString:mDuration];
}


#pragma mark Others

-(void)startActivityWithMsg:(NSString *)msg
{
	self.bubbleMsgLbl.hidden = NO;
	self.bubbleMsgLbl.text = msg;
	[self.activityView startAnimating];
}

-(void)stopActivity
{
	self.bubbleMsgLbl.hidden = YES;
	self.bubbleMsgLbl.text = nil;
	[self.activityView stopAnimating];
}

-(void)setBtnEnableStatus:(BOOL)enable
{
	self.startPause.enabled = enable;
	self.prevBtn.enabled = enable;
	self.nextBtn.enabled = enable;
	self.modeBtn.enabled = enable;
}

- (void)setupObservers
{
	NSNotificationCenter *def = [NSNotificationCenter defaultCenter];
    [def addObserver:self
			selector:@selector(applicationDidEnterForeground:)
				name:UIApplicationDidBecomeActiveNotification
			  object:[UIApplication sharedApplication]];
    [def addObserver:self
			selector:@selector(applicationDidEnterBackground:)
				name:UIApplicationWillResignActiveNotification
			  object:[UIApplication sharedApplication]];
}

- (void)unSetupObservers
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}


-(void)showVideoLoadingError
{
	NSString *sError = NSLocalizedString(@"Video cannot be played", @"description");
	NSString *sReason = NSLocalizedString(@"Video cannot be loaded.", @"reason");
	NSDictionary *errorDict = [NSDictionary dictionaryWithObjectsAndKeys:
							   sError, NSLocalizedDescriptionKey,
							   sReason, NSLocalizedFailureReasonErrorKey,
							   nil];
	NSError *error = [NSError errorWithDomain:@"Vitamio" code:0 userInfo:errorDict];
	UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[error localizedDescription]
														message:[error localizedFailureReason]
													   delegate:nil
											  cancelButtonTitle:@"OK"
											  otherButtonTitles:nil];
	[alertView show];
}

//#pragma mark -
//#pragma mark UIDevice InterfaceOrientations
//-(BOOL)shouldAutorotate{
//    return YES;
//}
//- (NSUInteger)supportedInterfaceOrientations{
//    return UIInterfaceOrientationMaskLandscape;
//}
//- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation{
//    return UIInterfaceOrientationIsLandscape(toInterfaceOrientation);
//}
- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
    
}
- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation{
    
}

-(BOOL)disablesAutomaticKeyboardDismissal
{
    return NO;
}



@end