//
//  PlayerViewController2.h
//  video
//
//  Created by Qeebu on 13-12-17.
//  Copyright (c) 2013年 Qeebu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Vitamio.h"
#import "PlayerControllerDelegate.h"

@interface PlayerViewController2 : UIViewController<VMediaPlayerDelegate>

@property (nonatomic, assign) id<PlayerControllerDelegate> delegate;


@end
