//
//  ViewController.m
//  musuctweet
//
//  Created by 中村一輝 on 2015/06/10.
//  Copyright (c) 2015年 中村一輝. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
   
    //アプリ終了時にfinish関数を呼び出す
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(finish)
                                                 name:UIApplicationDidEnterBackgroundNotification
                                               object:nil];
    
    // Do any additional setup after loading the view, typically from a nib.
    self.view.backgroundColor = [UIColor whiteColor];
    
    // ラベルの設定
    CGRect rect = CGRectMake(50, 100, 200, 100);
    UILabel *label = [[UILabel alloc]initWithFrame:rect];
    label.text = @"music tweet";
    label.textAlignment = NSTextAlignmentCenter;
    label.font = [UIFont fontWithName:@"Helvetica" size:32];
    label.textColor = [UIColor blackColor];
    label.numberOfLines = 1; // 0の場合は無制限
    [self.view addSubview:label];
    
    //ボタンの設定
    UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    button.frame = CGRectMake(50, 400, 200, 50);
    [button setTitle:@"音楽ライブラリを開いて再生" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(buttonWasTapped:)
     forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
}

    //ボタンが押された時に呼ばれる関数
- (void)buttonWasTapped:(UIButton *)button{
    MPMediaPickerController *picker = [[MPMediaPickerController alloc] initWithMediaTypes:MPMediaTypeMusic];
    [picker setDelegate: self];
    [picker setAllowsPickingMultipleItems: YES];
    picker.prompt = NSLocalizedString (@"Add songs to play", "Prompt in media item picker");
    picker.allowsPickingMultipleItems = YES;  //曲を複数選べるようにする
    [self presentViewController:picker animated:YES completion:nil];
}
    //曲を再生する関数
- (void) mediaPicker:(MPMediaPickerController *) mediaPicker
   didPickMediaItems:(MPMediaItemCollection *) collection {
    MPMediaItem *item = [collection.items lastObject];
    mediaPlayer = [[MPMusicPlayerController alloc] init];
    [mediaPlayer setQueueWithItemCollection:collection];
    [mediaPlayer setRepeatMode:MPMusicRepeatModeAll];
    [mediaPlayer play];
    
    for (MPMediaItem *item in collection.items) {
        NSLog(@"Title is %@", [item valueForProperty:MPMediaItemPropertyTitle]);
        NSLog(@"Artist is %@", [item valueForProperty:MPMediaItemPropertyArtist]);
        NSLog(@"Album Title = %@",[item valueForProperty:MPMediaItemPropertyAlbumTitle]);
    }
    
    NSString *setStringmusic =[NSString stringWithFormat:@"%@ / %@(%@)\n#musictweet",[item valueForProperty:MPMediaItemPropertyTitle],[item valueForProperty:MPMediaItemPropertyArtist],[item valueForProperty:MPMediaItemPropertyAlbumTitle]];
    
    //曲の内容があればツイッターに曲の内容を投稿する
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter]) {
        ACAccountStore *accountStore = [[ACAccountStore alloc] init];
        ACAccountType *accountType = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
        [accountStore
         requestAccessToAccountsWithType:accountType
         options:nil
         completion:^(BOOL granted, NSError *error) {
             if (granted) {
                 NSArray *accountArray = [accountStore accountsWithAccountType:accountType];
                 if (accountArray.count > 0) {
                     NSURL *url = [NSURL URLWithString:@"https://api.twitter.com/1/statuses/update.json"];
                     NSDictionary *params = [NSDictionary dictionaryWithObject:setStringmusic forKey:@"status"];
                     
                     SLRequest *request = [SLRequest requestForServiceType:SLServiceTypeTwitter
                                                             requestMethod:SLRequestMethodPOST
                                                                       URL:url
                                                                parameters:params];
                     [request setAccount:[accountArray objectAtIndex:0]];
                     [request performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
                         NSLog(@"responseData=%@", [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding]);
                     }];
                 }
             }
         }];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void) mediaPickerDidCancel:(MPMediaPickerController *) mediaPicker {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)finish{
    [mediaPlayer stop];
}

@end
