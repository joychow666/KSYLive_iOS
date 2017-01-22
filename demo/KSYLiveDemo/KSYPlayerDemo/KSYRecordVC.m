//
//  KSYRecordVC.m
//
//  Created by zengfanping on 11/3/15.
//  Copyright (c) 2015 zengfanping. All rights reserved.
//

#import "KSYRecordVC.h"
#import <CommonCrypto/CommonDigest.h>
#import "KSYProgressView.h"
#import "KSYUIRecorderKit.h"
#import <GPUImage/GPUImage.h>

@interface KSYRecordVC () <UITextFieldDelegate>
@property (strong, nonatomic) NSURL *url;
@property (strong, nonatomic) KSYMoviePlayerController *player;
@property  KSYUIRecorderKit* kit;
@end

@implementation KSYRecordVC{
    UILabel *stat;
    UIView *videoView;
    UIButton *btnPlay;
    UIButton *btnPause;
    UIButton *btnResume;
    UIButton *btnStop;
    UIButton *btnQuit;
    
    UILabel  *lableHWCodec;
    UISwitch  *switchHwCodec;
    
    UILabel *labelVolume;
    UISlider *sliderVolume;
    
    UIButton *btnStartRecord;
    UIButton *btnStopRecord;
    
    NSString *recordFilePath;
}

- (instancetype)initWithURL:(NSURL *)url {
    if((self = [super init])) {
        self.url = url;
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initUI];
    
    [self setupUIKit];
}

- (void) initUI {
    videoView = [[UIView alloc] init];
    videoView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:videoView];

    btnPlay = [self addButtonWithTitle:@"播放" action:@selector(onPlayVideo:)];
    btnPause = [self addButtonWithTitle:@"暂停" action:@selector(onPauseVideo:)];
    btnResume = [self addButtonWithTitle:@"继续" action:@selector(onResumeVideo:)];
    btnStop = [self addButtonWithTitle:@"停止" action:@selector(onStopVideo:)];
    btnQuit = [self addButtonWithTitle:@"退出" action:@selector(onQuit:)];
    btnStartRecord = [self addButtonWithTitle:@"开始录屏" action:@selector(onStartRecordVideo:)];
    btnStopRecord =[self addButtonWithTitle:@"停止录屏" action:@selector(onStopRecordVideo:)];
    btnStartRecord.enabled = NO;
    btnStopRecord.enabled = NO;

	stat = [[UILabel alloc] init];
    stat.backgroundColor = [UIColor clearColor];
    stat.textColor = [UIColor redColor];
    stat.numberOfLines = -1;
    stat.textAlignment = NSTextAlignmentLeft;
    [self.view addSubview:stat];
    
    lableHWCodec = [[UILabel alloc] init];
    lableHWCodec.text = @"硬解码";
    lableHWCodec.textColor = [UIColor lightGrayColor];
    [self.view addSubview:lableHWCodec];
    
    labelVolume = [[UILabel alloc] init];
    labelVolume.text = @"音量";
    labelVolume.textColor = [UIColor lightGrayColor];
    [self.view addSubview:labelVolume];
    
    switchHwCodec = [[UISwitch alloc] init];
    [self.view  addSubview:switchHwCodec];
    switchHwCodec.on = YES;
    
    sliderVolume = [[UISlider alloc] init];
    sliderVolume.minimumValue = 0;
    sliderVolume.maximumValue = 100;
    sliderVolume.value = 100;
    [sliderVolume addTarget:self action:@selector(onVolumeChanged:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:sliderVolume];

    [self layoutUI];
    
    [self.view bringSubviewToFront:stat];
    stat.frame = [UIScreen mainScreen].bounds;

}
- (UIButton *)addButtonWithTitle:(NSString *)title action:(SEL)action{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [button setTitle:title forState: UIControlStateNormal];
    button.backgroundColor = [UIColor lightGrayColor];
    [button addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    button.layer.masksToBounds  = YES;
    button.layer.cornerRadius   = 5;
    button.layer.borderColor    = [UIColor blackColor].CGColor;
    button.layer.borderWidth    = 1;
    [self.view addSubview:button];
    return button;
}
- (void) layoutUI {
    CGFloat wdt = self.view.bounds.size.width;
    CGFloat hgt = self.view.bounds.size.height;
    CGFloat gap =15;
    CGFloat btnWdt = ( (wdt-gap) / 5) - gap;
    CGFloat btnHgt = 30;
    CGFloat xPos = 0;
    CGFloat yPos = 0;
    
    yPos = 2 * gap;
    xPos = gap;
    labelVolume.frame = CGRectMake(xPos, yPos, btnWdt, btnHgt);
    xPos += btnWdt + gap;
    sliderVolume.frame  = CGRectMake(xPos, yPos, wdt - 3 * gap - btnWdt, btnHgt);
    yPos += btnHgt + gap;
    xPos = gap;
    lableHWCodec.frame =CGRectMake(xPos, yPos, btnWdt * 2, btnHgt);
    xPos += btnWdt + gap;
    switchHwCodec.frame = CGRectMake(xPos, yPos, btnWdt, btnHgt);
    
    videoView.frame = CGRectMake(0, 0, wdt, hgt);
    
    xPos = gap;
    yPos = hgt - btnHgt - gap;
    btnPlay.frame = CGRectMake(xPos, yPos, btnWdt, btnHgt);
    xPos += gap + btnWdt;
    btnPause.frame = CGRectMake(xPos, yPos, btnWdt, btnHgt);
    xPos += gap + btnWdt;
    btnResume.frame = CGRectMake(xPos, yPos, btnWdt, btnHgt);
    xPos += gap + btnWdt;
    btnStop.frame = CGRectMake(xPos, yPos, btnWdt, btnHgt);
    xPos += gap + btnWdt;
    btnQuit.frame = CGRectMake(xPos, yPos, btnWdt, btnHgt);
    
    xPos = gap;
    yPos -= (btnHgt + gap);
    
    CGFloat newWidth = btnWdt*2;
    btnStartRecord.frame = CGRectMake(xPos, yPos, newWidth, btnHgt);
    xPos += gap + newWidth;
    btnStopRecord.frame = CGRectMake(xPos, yPos, newWidth, btnHgt);
}

- (BOOL)shouldAutorotate {
    [self layoutUI];
    return YES;
}

-(void)onVolumeChanged:(UISlider *)slider
{
    if (_player){
        [_player setVolume:slider.value/100 rigthVolume:slider.value/100];
    }
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)handlePlayerNotify:(NSNotification*)notify
{
    if (!_player) {
        return;
    }
    
    if (MPMoviePlayerPlaybackDidFinishNotification ==  notify.name) {
        int reason = [[[notify userInfo] valueForKey:MPMoviePlayerPlaybackDidFinishReasonUserInfoKey] intValue];
        if (reason ==  MPMovieFinishReasonPlaybackEnded) {
            stat.text = [NSString stringWithFormat:@"player finish"];
        }else if (reason == MPMovieFinishReasonPlaybackError){
            stat.text = [NSString stringWithFormat:@"player Error : %@", [[notify userInfo] valueForKey:@"error"]];
        }else if (reason == MPMovieFinishReasonUserExited){
            stat.text = [NSString stringWithFormat:@"player userExited"];
        }
    }
}

- (void) toast:(NSString*)message{
    UIAlertView *toast = [[UIAlertView alloc] initWithTitle:nil
                                                    message:message
                                                   delegate:nil
                                          cancelButtonTitle:nil
                                          otherButtonTitles:nil, nil];
    [toast show];
    
    double duration = 0.5; // duration in seconds
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(duration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [toast dismissWithClickedButtonIndex:0 animated:YES];
    });
}

- (void)setupObservers
{
    [[NSNotificationCenter defaultCenter]addObserver:self
                                            selector:@selector(handlePlayerNotify:)
                                                name:(MPMoviePlayerPlaybackDidFinishNotification)
                                              object:_player];
    
    
    [[NSNotificationCenter defaultCenter]addObserver:self
                                            selector:@selector(onStreamStateChange:)
                                                name:(KSYStreamStateDidChangeNotification)
                                              object:nil];
}

- (void)releaseObservers 
{
    [[NSNotificationCenter defaultCenter]removeObserver:self
                                                   name:MPMoviePlayerPlaybackDidFinishNotification
                                                 object:_player];
    
    
    [[NSNotificationCenter defaultCenter]removeObserver:self
                                                   name:KSYStreamStateDidChangeNotification
                                                 object:nil];
}

- (void)initPlayerWithURL:(NSURL *)aURL {
    self.player = [[KSYMoviePlayerController alloc] initWithContentURL:_url sharegroup:[[[GPUImageContext sharedImageProcessingContext] context] sharegroup]];
    [self setupObservers];
    
    //player视频数据输入
    __weak KSYUIRecorderKit* weakKit = _kit;
    _player.textureBlock = ^(GLuint textureId, int width, int height, double pts){
        CGSize size = CGSizeMake(width, height);
        CMTime _pts = CMTimeMake((int64_t)(pts * 1000), 1000);
        [weakKit processWithTextureId:textureId TextureSize:size Time:_pts];
    };
    
    //player音频数据输入
    _player.audioDataBlock = ^(CMSampleBufferRef buf){
        CMTime pts = CMSampleBufferGetPresentationTimeStamp(buf);
        if(pts.value < 0)
        {
            NSLog(@"audio pts < 0");
            return;
        }
        [weakKit processAudioSampleBuffer:buf];
    };
    
    _player.videoDecoderMode = switchHwCodec.isOn? MPMovieVideoDecoderMode_Hardware : MPMovieVideoDecoderMode_Software;
    [_player.view setFrame: videoView.bounds];
    [videoView addSubview: _player.view];
    [videoView bringSubviewToFront:stat];
    
    [_player prepareToPlay];
}

- (IBAction)onPlayVideo:(id)sender {
    
    if(nil == _player)
    {
        [self initPlayerWithURL:_url];
        btnStartRecord.enabled = YES;
        btnStopRecord.enabled = NO;
    } else {
        [_player setUrl:[NSURL URLWithString:@"rtmp://live.hkstv.hk.lxdns.com/live/hks"]];
        [_player prepareToPlay];
    }
}
- (IBAction)onPauseVideo:(id)sender {
    if (_player) {
        [_player pause];
    }
}

- (IBAction)onResumeVideo:(id)sender {
    if (_player) {
        [_player play];
    }
}


- (IBAction)onStopVideo:(id)sender {
    if (_player) {
        [_player stop];
        [self releaseObservers];
        [_player.view removeFromSuperview];
        self.player = nil;
    }
}

- (IBAction)onQuit:(id)sender {
    [self onStopVideo:nil];
    [self dismissViewControllerAnimated:FALSE completion:nil];
    stat.text = nil;
}


#pragma record kit setup
-(void)setupUIKit{
    recordFilePath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/RecordAv.mp4"];
    _kit = [[KSYUIRecorderKit alloc]init];
    [self addUIToKit];
}

-(void)addUIToKit{
    
    [_kit.contentView addSubview:labelVolume];
    [_kit.contentView addSubview:sliderVolume];
    [_kit.contentView addSubview:lableHWCodec];
    [_kit.contentView addSubview:switchHwCodec];
    [_kit.contentView addSubview:btnPlay];
    [_kit.contentView addSubview:btnPause];
    [_kit.contentView addSubview:btnResume];
    [_kit.contentView addSubview:btnStop];
    [_kit.contentView addSubview:btnQuit];
    [_kit.contentView addSubview:btnStartRecord];
    [_kit.contentView addSubview:btnStopRecord];
    [_kit.contentView addSubview:stat];
    
    [_kit.contentView addSubview:_player.view];
    [self.view addSubview:_kit.contentView];
    [_kit.contentView sendSubviewToBack:videoView];
}

-(IBAction)onStartRecordVideo:(id)sender{
    [self deleteFile:recordFilePath];
    NSURL * path =[[NSURL alloc] initWithString:recordFilePath];
    [_kit startRecord:path];
    btnStartRecord.enabled = NO;
    btnStopRecord.enabled = YES;
}

-(IBAction)onStopRecordVideo:(id)sender{
    [_kit stopRecord];
    btnStartRecord.enabled = YES;
    btnStopRecord.enabled = NO;
}

- (void) onStreamError:(KSYStreamErrorCode) errCode{
    if (errCode == KSYStreamErrorCode_CONNECT_BREAK) {
        // Reconnect
        [self tryReconnect];
    }
    else if (errCode == KSYStreamErrorCode_AV_SYNC_ERROR) {
        NSLog(@"audio video is not synced, please check timestamp");
        [self tryReconnect];
    }
    else if (errCode == KSYStreamErrorCode_CODEC_OPEN_FAILED) {
        NSLog(@"video codec open failed, try software codec");
        _kit.writer.videoCodec = KSYVideoCodec_X264;
        [self tryReconnect];
    }
}
- (void) tryReconnect {
    dispatch_time_t delay = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC));
    dispatch_after(delay, dispatch_get_main_queue(), ^{
        NSLog(@"try again");
        NSURL * path =[[NSURL alloc] initWithString:recordFilePath];
        [_kit startRecord:path];
    });
}

- (void) onStreamStateChange :(NSNotification *)notification{
    if (_kit.writer){
        NSLog(@"stream State %@", [_kit.writer getCurStreamStateName]);
    }
    //状态为KSYStreamStateIdle且_bRecord为ture时，录制视频
    if (_kit.writer.streamState == KSYStreamStateIdle && _kit.bPlayRecord == NO){
        [self saveVideoToAlbum: recordFilePath];
    }
    
    if (_kit.writer.streamState == KSYStreamStateError){
        [self onStreamError:_kit.writer.streamErrorCode];
    }
}

//保存视频到相簿
- (void) saveVideoToAlbum: (NSString*) path {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:path]) {
        return;
    }
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            if (UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(path)) {
                SEL onDone = @selector(video:didFinishSavingWithError:contextInfo:);
                UISaveVideoAtPathToSavedPhotosAlbum(path, self, onDone, nil);
            }
    });
}
//保存mp4文件完成时的回调
- (void)video:(NSString *)videoPath didFinishSavingWithError:(NSError *)error
  contextInfo:(void *)contextInfo {
    NSString *message;
    if (!error) {
        message = @"Save album success!";
    }
    else {
        message = @"Failed to save the album!";
    }
    [self toast:message];
}

//删除文件,保证保存到相册里面的视频时间是更新的
-(void)deleteFile:(NSString *)file{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:file]) {
        [fileManager removeItemAtPath:file error:nil];
    }
}

@end
