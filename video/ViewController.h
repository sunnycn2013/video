//
//  ViewController.h
//  video
//
//  Created by Qeebu on 13-12-16.
//  Copyright (c) 2013年 Qeebu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PlayerControllerDelegate.h"


@interface ViewController : UIViewController<PlayerControllerDelegate>

-(IBAction)playButtonAction:(id)sender;


@end
