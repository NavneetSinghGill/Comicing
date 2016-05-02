//
//  ComicItemTools.m
//  ComicMakingPage
//
//  Created by Ramesh on 25/01/16.
//  Copyright © 2016 ADNAN THATHIYA. All rights reserved.
//

#import "ComicItem.h"
#import "AppConstants.h"
#import "AppHelper.h"

@implementation ComicItemSticker

- (id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self != nil) {
        self.frame = frame;
    }
    return self;
}

-(id)addItemWithImage:(id)sticker{
    
//    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 150, 150)];
    self.contentMode = UIViewContentModeScaleAspectFit;
    self.image = sticker;
    
    return self;
}

- (id)initWithCoder:(NSCoder *)decoder{
    self = [super init];
    if (self)
    {
        self.transform = CGAffineTransformFromString([decoder decodeObjectForKey:@"stickerTransform"]);
        self.image = [UIImage imageWithData:[decoder decodeObjectForKey:@"stickerimage"]];
        self.frame = CGRectFromString([decoder decodeObjectForKey:@"stickerFrame"]);
//        self.center = CGPointFromString([decoder decodeObjectForKey:@"stickerCenter"]);
//        NSLog(@"encodeWithCoder transform %@",NSStringFromCGAffineTransform(self.transform));
    }
    
    return [self initWithFrame:[self frame]];
}
-(void)encodeWithCoder:(NSCoder *)aCoder{
    
    [aCoder encodeObject:UIImagePNGRepresentation(self.image) forKey:@"stickerimage"];
    [aCoder encodeObject:NSStringFromCGRect(self.frame) forKey:@"stickerFrame"];
    [aCoder encodeObject:NSStringFromCGAffineTransform(self.transform) forKey:@"stickerTransform"];
//    [aCoder encodeObject:NSStringFromCGPoint(self.center) forKey:@"stickerCenter"];
//    NSLog(@"encodeWithCoder transform %@",NSStringFromCGAffineTransform(self.transform));
}
@end


@implementation ComicItemExclamation

- (id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self != nil) {
        self.frame = frame;
    }
    return self;
}

-(id)addItemWithImage:(id)sticker{
    
    //    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 150, 150)];
    self.contentMode = UIViewContentModeScaleAspectFit;
    self.image = sticker;
    
    return self;
}

- (id)initWithCoder:(NSCoder *)decoder{
    self = [super init];
    if (self)
    {
        self.image = [UIImage imageWithData:[decoder decodeObjectForKey:@"exclamationimage"]];
        self.frame = CGRectFromString([decoder decodeObjectForKey:@"exclamationFrame"]);
    }
    
    return [self initWithFrame:[self frame]];
}
-(void)encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeObject:UIImagePNGRepresentation(self.image) forKey:@"exclamationimage"];
    [aCoder encodeObject:NSStringFromCGRect(self.frame) forKey:@"exclamationFrame"];
}

@end

@implementation ComicItemBubble

@synthesize recorderFilePath,player;

- (id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self != nil) {
        self.frame = frame;
    }
    return self;
}

-(id)addItemWithImage:(id)sticker{
    
    //    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 150, 150)];
    self.contentMode = UIViewContentModeScaleAspectFit;
    
    return self;
}

#pragma mark AudioAction

-(BOOL)isPlayVoice{
    if (recorderFilePath)
    return YES;
    else
    return NO;
}

- (void)recordAction{
    
    [[GoogleAnalytics sharedGoogleAnalytics] logUserEvent:@"VoiceRecord" Action:@"Create" Label:@""];
    
    if (audioSession == nil) {
        audioSession =[AVAudioSession sharedInstance];
    }
    BOOL audioHWAvailable = audioSession.inputAvailable;
    if (! audioHWAvailable) {
        UIAlertView *cantRecordAlert =
        [[UIAlertView alloc] initWithTitle: @"Warning"
                                   message: @"Audio input hardware not available"
                                  delegate: nil
                         cancelButtonTitle:@"OK"
                         otherButtonTitles:nil];
        [cantRecordAlert show];
        return;
    }
    else{
        
        if ([self startRecording].length != 0)
        {
            NSError *err = nil;
            if(err){
                return;
            }
            temporaryRecFile = [NSURL fileURLWithPath:[self startRecording]];
            NSMutableDictionary *recordSetting = [[NSMutableDictionary alloc] init];
            
            [recordSetting setValue :[NSNumber numberWithInt:kAudioFormatLinearPCM] forKey:AVFormatIDKey];
            [recordSetting setValue:[NSNumber numberWithFloat:44100.0] forKey:AVSampleRateKey];
            [recordSetting setValue:[NSNumber numberWithInt: 2] forKey:AVNumberOfChannelsKey];
            
            [recordSetting setValue :[NSNumber numberWithInt:16] forKey:AVLinearPCMBitDepthKey];
            [recordSetting setValue :[NSNumber numberWithBool:NO] forKey:AVLinearPCMIsBigEndianKey];
            [recordSetting setValue :[NSNumber numberWithBool:NO] forKey:AVLinearPCMIsFloatKey];
            
            err = nil;
            recorder = [[ AVAudioRecorder alloc] initWithURL:temporaryRecFile settings:recordSetting error:&err];
            if(!recorder){
                UIAlertView *alert =
                [[UIAlertView alloc] initWithTitle: @"Warning"
                                           message: [err localizedDescription]
                                          delegate: nil
                                 cancelButtonTitle:@"OK"
                                 otherButtonTitles:nil];
                [alert show];
                return;
            }
            
            //prepare to record
            [recorder setDelegate:self];
            [recorder prepareToRecord];
            recorder.meteringEnabled = YES;
            
            // start recording
            //                [recorder recordForDuration:(NSTimeInterval) 10];
            [recorder record];
        }
        else
        {
            NSLog(@"not recording");
            [recorder stop];
        }
    }
}

- (void)pauseAction{
    [recorder pause];
}

-(float)playDuration{
    if(!recorderFilePath)
    return 0.0;
    
    NSError* error;
    NSURL *filePath = [NSURL fileURLWithPath:recorderFilePath isDirectory:NO];
    
    player =[[AVAudioPlayer alloc] initWithContentsOfURL:filePath error:&error];
    [player setDelegate:self];
    [player prepareToPlay];
    
    long seconds = lroundf(player.duration); // Since modulo operator (%) below needs int or long
    float secs = seconds % 60;
    return secs;
}

- (void)playAction {
    if(!recorderFilePath)
    recorderFilePath = [NSString stringWithFormat:@"%@.caf", DOCUMENTS_FOLDER] ;
    
    if (!player) {
        NSError* error;
        NSURL *filePath = [NSURL fileURLWithPath:recorderFilePath isDirectory:NO];
        player =[[AVAudioPlayer alloc] initWithContentsOfURL:filePath error:&error];
        [player setDelegate:self];
        [player prepareToPlay];
    }
    [player play];
    
}
- (NSString *)startRecording{
    
    if (audioSession == nil) {
        audioSession = [AVAudioSession sharedInstance];
    }
    NSError *err = nil;
    [audioSession setCategory :AVAudioSessionCategoryPlayAndRecord error:&err];
    if(err){
        return @"";
    }
    [audioSession setActive:YES error:&err];
    err = nil;
    if(err){
        return @"";
    }
    // Create a new dated file
    // we need to add extra identifier for each sound
    NSString * timestamp = [NSString stringWithFormat:@"%f",[[NSDate date] timeIntervalSince1970] * 1000];
    recorderFilePath = [NSString stringWithFormat:@"%@_%@.caf",DOCUMENTS_FOLDER,timestamp] ;
    return recorderFilePath;
}

- (void)stopRecording{
    if (player) {
        [player pause];
    }
    [recorder stop];
    
    //    NSURL *url = [NSURL fileURLWithPath:recorderFilePath];
    //    NSError *err = nil;
    //    NSData *audioData = [NSData dataWithContentsOfFile:[url path] options: 0 error:&err];
    //    if(!audioData)
    //        return;
    //
    //    NSFileManager *fm = [NSFileManager defaultManager];
    //
    //    err = nil;
    ////    [fm removeItemAtPath:[url path] error:&err];
    //    if(err)
    //        return;
}

- (void)audioRecorderDidFinishRecording:(AVAudioRecorder *) aRecorder successfully:(BOOL)flag{
    NSLog (@"audioRecorderDidFinishRecording:successfully:");
}
- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag{
    NSLog (@"audioRecorderDidFinishRecording:successfully:");
}
- (void)playerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError *)error{
    NSLog(@"ERROR IN DECODE: %@\n", error);
}
- (void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player
                                 error:(NSError *)error{
    NSLog(@"ERROR IN DECODE: %@\n", error);
}
- (id)initWithCoder:(NSCoder *)decoder {
    if ((self = [super initWithCoder:decoder])) {
        self.imageView = [decoder decodeObjectForKey:@"imageView"];
        
        if (SYSTEM_VERSION_LESSER_THAN_OR_EQUAL_TO(@"9")) {
            self.imageView.image = [UIImage imageWithData:[decoder decodeObjectForKey:@"bubbleimage"]];
        }else{
            self.imageView.image = [decoder decodeObjectForKey:@"bubbleimage"];
        }
        self.recorderFilePath = [decoder decodeObjectForKey:@"recorderFilePath"];
        self.audioImageButton = [decoder decodeObjectForKey:@"audioImageButton"];
        self.txtBuble = [decoder decodeObjectForKey:@"txtBuble"];
        self.imagebtn = [decoder decodeObjectForKey:@"imagebtn"];
        self.bubbleString = [decoder decodeObjectForKey:@"bubbleString"];
        
    }
    return self;
}
-(void)encodeWithCoder:(NSCoder *)aCoder{
    if (SYSTEM_VERSION_LESSER_THAN_OR_EQUAL_TO(@"9")) {
        [aCoder encodeObject:UIImagePNGRepresentation(self.imageView.image) forKey:@"bubbleimage"];
    }else{
        [aCoder encodeObject:self.imageView.image forKey:@"bubbleimage"];
    }
    [aCoder encodeObject:self.recorderFilePath forKey:@"recorderFilePath"];
    [aCoder encodeObject:self.audioImageButton forKey:@"audioImageButton"];
    [aCoder encodeObject:self.imageView forKey:@"imageView"];
    [aCoder encodeObject:self.txtBuble forKey:@"txtBuble"];
    [aCoder encodeObject:self.imagebtn forKey:@"imagebtn"];
    [aCoder encodeObject:self.bubbleString forKey:@"bubbleString"];
}

-(void)dealloc
{
//    self.txtBuble = nil;
}

@end

@implementation ComicItemCaption

- (id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self != nil) {
        self.frame = frame;
    }
    return self;
}
-(id)addItemWithImage:(id)sticker{
    
    //    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 150, 150)];
    self.contentMode = UIViewContentModeScaleAspectFit;
    
    return self;
}
- (id)initWithCoder:(NSCoder *)decoder {
    if ((self = [super initWithCoder:decoder])) {
        self.bgImageView = [decoder decodeObjectForKey:@"bgImageView"];
        self.txtCaption = [decoder decodeObjectForKey:@"txtCaption"];
        self.plusButton = [decoder decodeObjectForKey:@"plusButton"];
        self.dotHolder = [decoder decodeObjectForKey:@"dotHolder"];
        self.tintColourString = [decoder decodeObjectForKey:@"tintColourString"];
        
    }
    return self;
}
-(void)encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeObject:self.tintColourString forKey:@"tintColourString"];
    [aCoder encodeObject:self.bgImageView forKey:@"bgImageView"];
    [aCoder encodeObject:self.txtCaption forKey:@"txtCaption"];
    [aCoder encodeObject:self.plusButton forKey:@"plusButton"];
    [aCoder encodeObject:self.dotHolder forKey:@"dotHolder"];
}

@end