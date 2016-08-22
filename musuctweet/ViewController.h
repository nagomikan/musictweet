//
//  ViewController.h
//  musuctweet
//
//  Created by 中村一輝 on 2015/06/10.
//  Copyright (c) 2015年 中村一輝. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import <Accounts/Accounts.h>
#import <Twitter/Twitter.h>

@interface ViewController : UIViewController<MPMediaPickerControllerDelegate>{
    MPMusicPlayerController *mediaPlayer;
}



@end

