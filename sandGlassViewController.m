//
//  sandGlassViewController.m
//  PhotoGlass
//
//  Created by 梶原 一葉 on 9/3/14.
//  Copyright (c) 2014 梶原 一葉. All rights reserved.
//

//一番新しいやつうううういやほおおおおお


#import "sandGlassViewController.h"
#import "Image.h"
#import "mosaicViewController.h"
#import "UIImage+GIF.h"
#import "WSCoachMarksView.h"
#import "ELCImagePickerController.h"
#import "ELCAlbumPickerController.h"

@interface sandGlassViewController ()
@end

@implementation sandGlassViewController
{
    NSMutableArray *picImgViewArray;
}
-(id)init
{
    picImgViewArray = [NSMutableArray array];
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    
    /* ---　背景画像設定 --- */
    back = [UIImage imageNamed:@"sunaset.png"];
    backView = [[UIImageView alloc] initWithImage:back];
    backView.frame = CGRectMake(0, 0, 320, 568);
    
    //gifアニメーション
    UIImage *sunaImage = [UIImage animatedGIFNamed:@"砂"];
    sunaImageView = [[UIImageView alloc] initWithImage:sunaImage];
    sunaImageView.frame = CGRectMake(158, 275, 5, 128);
    
    [self.view addSubview:backView];
    [self.view addSubview:sunaImageView];
    
    //端末回転通知の開始
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didRotate:)
                                                 name:UIDeviceOrientationDidChangeNotification
                                               object:nil];
    
    //UIImagePickerController
    _pickerController =[[UIImagePickerController alloc] init];
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]){_pickerController.sourceType = UIImagePickerControllerSourceTypeCamera;}
    _pickerController.delegate = self;
    _pickerController.allowsEditing = YES;
    
    _AlbumName = @"PhotoGlass";
    _albumWasFound = FALSE;
    
    // Weak 参照を持つ
    __weak typeof(self) weakSelf = self;
        _library = [[ALAssetsLibrary alloc] init];
    [_library addAssetsGroupAlbumWithName:_AlbumName
                              resultBlock: ^(ALAssetsGroup *group) {
                                  // アルバムが既に存在する場合、group には nil が入る
                                  
                                  if (group == nil) {
                                      NSLog(@"もうあるよ");
                                      return;
                                  } NSLog(@"動いてる");
                                  // Strong 参照させる（ブロックの最後まで値がキープされるようにするために）
                                  __strong typeof(self) strongSelf = weakSelf;
                                  
                                  strongSelf->_groupURL = [group valueForProperty:ALAssetsGroupPropertyURL];
                                  ELCAlbumPickerController *albumController = [[ELCAlbumPickerController alloc] init];
                                  ELCImagePickerController *elcPickerController = [[ELCImagePickerController alloc] initWithRootViewController:albumController];
                                  [albumController setParent:elcPickerController];
                                  [elcPickerController setImagePickerDelegate:self];
                                  
                                  [self presentViewController:elcPickerController animated:YES completion:nil];
                              }
                             failureBlock:nil];
}


/* ---- PhotoGlassフォルダに画像追加する ---- */
//きちんと選んだとき
- (void)elcImagePickerController:(ELCImagePickerController *)picker didFinishPickingMediaWithInfo:(NSArray *)info
{
    [self dismissViewControllerAnimated:YES completion:nil];
    if ([info count] < 1) {
        return;
    }
    
    UIImage *image;
    for (NSMutableDictionary *item in info) {
        image = [item objectForKey:UIImagePickerControllerOriginalImage];
    }
    
    
}
//キャンセルしたとき
- (void)elcImagePickerControllerDidCancel:(ELCImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
    
}

-(void)viewDidAppear:(BOOL)animated{
    
    [self makeImgParts];
    
}
 


-(void)makeImgParts{
    
    /* --- 時間 --- */
    NSDate *begin =[[NSUserDefaults standardUserDefaults] objectForKey:@"begin"];
    
    if(begin== nil){
        begin = [NSDate date]; //使い始めた日にちをbeginにいれる
        [[NSUserDefaults standardUserDefaults] setObject:begin forKey:@"begin"]; //開始時刻を保存
    }
    
    // 削除する
    for (int i = (int)picImgViewArray.count - 1; i >= 0; i--) {
        [picImgViewArray[i] removeFromSuperview];
        //[picImgViewArray[i] removeFromSuperview];
    }
    
    [picImgViewArray removeAllObjects];
    
    /* --- 写真 --- */
    ALAssetsLibrary *assetsLibrary = [[ALAssetsLibrary alloc] init];
    
    [assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos
                                 usingBlock:^(ALAssetsGroup *group, BOOL *stop)
     {
         NSMutableArray *array = [[NSMutableArray alloc] init];
         
         //NSLog(@"number %d",(int)[group numberOfAssets]);
         //NSLog(@"group is %@",group);
         //[[self.view subviews]
         //makeObjectsPerformSelector:@selector(removeFromSuperview)];
         
         if ([[group valueForProperty:ALAssetsGroupPropertyName] isEqualToString:@"Camera Roll"])
         {
             [group setAssetsFilter:[ALAssetsFilter allPhotos]]; //全部の写真とってくる(movieはない)
             //__block int f = 0;
             //NSMutableArray *array = [[NSMutableArray alloc] init];
             for(int p = (int)[group numberOfAssets]-1; p >=(int)[group numberOfAssets]-42 && p>= 0 ; p--)
                 //[group numberOfAssets]は個数、pは順番(0から始まる)→0が一番古い写真
             {
                 //NSLog(@"p is %d",[group numberOfAssets]);
                 [group enumerateAssetsAtIndexes:[NSIndexSet indexSetWithIndex:p]
                                         options:0
                                      usingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop)
                  {
                      assetDate = [result valueForProperty:ALAssetPropertyDate]; //メタデータの中の日付のみ取得
                      
                      NSTimeInterval  since = [assetDate timeIntervalSinceDate:begin]; //現在時刻からbeginまでの秒数
                      
                      //NSLog(@"result =============== %@",result);
                      //NSLog(@"メタデータ-------%@",[[result defaultRepresentation] metadata]);
                      
                      if(since/(60*60*24) > -10){
                          
                          //NSLog(@"since is %f",since/(60*60*24));
                          
                          if (nil != result) {
                              
                              //NSArray *array = [[NSArray alloc] init];
                              //NSLog(@"%d",(int)[group numberOfAssets]);
                              
                              
                              ALAssetRepresentation *assetRespresentation = [result defaultRepresentation];
                              
                              UIImage *picImg = [UIImage imageWithCGImage:[assetRespresentation fullScreenImage]]; //フルスクリーンサイズの画像をpicImgにいれる
                              
                              
                              
                              int i = (int)[group numberOfAssets]-p-1; //最新の写真が0
                              //NSMutableArray *array = [[NSMutableArray alloc] init];
                              [array addObject:[NSNumber numberWithInteger:i]];
                              
                              
                              NSLog(@"----------------%d",i);
                              NSLog(@"配列の数　%d",(int)[array count]);
                              
                              
                              int x = 0; //x座標
                              int y = 0;
                              
                              double n = pow(-1, i);  //-1をi乗した数をresultにいれる
                              
                              if(i==0){
                                  picImgView = [[UIImageView alloc] initWithFrame:CGRectMake(148, 515, 24, 24)];
                                  
                                  NSLog(@"i %d",i);
                              }
                              
                              
                              else if(0<i && i<=4){
                                  for (i = (int)[group numberOfAssets]-p-6; i <=(int)[group numberOfAssets]-p-6; i++)
                                  {
                                      NSLog(@"ww %d",(int)[group numberOfAssets]);
                                      NSLog(@"p %d",p);
                                      NSLog(@"i %d",i);
                                      NSLog(@"おーい");
                                      x = 148 +26 *(i/2 + i%2)*n;
                                      y = 515+(i-1)/2*4;
                                      NSLog(@"x is %d",x);
                                      //[array addObject:[NSNumber numberWithInteger:x]];
                                      
                                      
                                      picImgView = [[UIImageView alloc] initWithFrame:CGRectMake(x, y, 24, 24)];
                                  }
                              }
                              
                              
                              
                              else if(4<i && i<=6){
                                  for (i = (int)[group numberOfAssets]-p-1; i <=(int)[group numberOfAssets]-p-1; i++)
                                  {
                                      NSLog(@"i %d",i);
                                      
                                      x = 148 +24 *(i/2 + i%2)*n;
                                      y = 500-(i-1)/2*4;
                                      //[array addObject:[NSNumber numberWithInteger:x]];
                                      
                                      picImgView = [[UIImageView alloc] initWithFrame:CGRectMake(x, y, 24, 24)];
                                  }
                              }
                              
                              
                              
                              
                              
                              
                              
                              //2段目
                              
                              else if(i==7){
                                  picImgView = [[UIImageView alloc] initWithFrame:CGRectMake(148, 488, 24, 24)];
                                  NSLog(@"i %d",i);
                              }
                              
                              else if(7<i && i<=9){
                                  for (i = (int)[group numberOfAssets]-p-8; i <=(int)[group numberOfAssets]-p-8; i++)
                                  {
                                      
                                      NSLog(@"ww %d",(int)[group numberOfAssets]);
                                      NSLog(@"p %d",p);
                                      NSLog(@"i %d",i);
                                      
                                      x = 148 +24 *(i/2 + i%2)*n;
                                      y = 484.5+(i-1)/2*0;
                                      NSLog(@"y %d",y);
                                      
                                      picImgView = [[UIImageView alloc] initWithFrame:CGRectMake(x, y, 24, 24)];
                                  }
                              }
                              else if(9<i && i<=11){
                                  for (i = (int)[group numberOfAssets]-p-8; i <=(int)[group numberOfAssets]-p-8; i++)
                                  {
                                      
                                      NSLog(@"ww %d",(int)[group numberOfAssets]);
                                      NSLog(@"p %d",p);
                                      NSLog(@"i %d",i);
                                      
                                      x = 148 +24 *(i/2 + i%2)*n;
                                      y = 481+(i-1)/2*0;
                                      NSLog(@"y %d",y);
                                      
                                      picImgView = [[UIImageView alloc] initWithFrame:CGRectMake(x, y, 24, 24)];
                                  }
                              }
 
                               //3段目
                               else if(i==21){
                               picImgView = [[UIImageView alloc] initWithFrame:CGRectMake(148, 450, 24, 24)];
                               NSLog(@"i %d",i);
                               }
                               
                               else if(21<i && i<=25){
                               for (i = (int)[group numberOfAssets]-p-22; i <=(int)[group numberOfAssets]-p-22; i++)
                               {
                               NSLog(@"i %d",i);
                               
                               x = 148 +24 *(i/2 + i%2)*n;
                               y = 452+(i-1)/2*5;
                               
                               picImgView = [[UIImageView alloc] initWithFrame:CGRectMake(x, y, 24, 24)];
                               }
                               }
                               else if(25<i && i<=27){
                               for (i = (int)[group numberOfAssets]-p-22; i <=(int)[group numberOfAssets]-p-22; i++)
                               {
                               NSLog(@"i %d",i);
                               
                               x = 148 +23 *(i/2 + i%2)*n;
                               
                               //[array addObject:[NSNumber numberWithInteger:x]];
                               picImgView = [[UIImageView alloc] initWithFrame:CGRectMake(x, 469, 24, 24)];
                               }
                               }
                               else if(27<i && i<=29){
                               for (i = (int)[group numberOfAssets]-p-22; i <=(int)[group numberOfAssets]-p-22; i++)
                               {
                               NSLog(@"i %d",i);
                               
                               x= 148 +23 *(i/2 + i%2)*n;
                               
                               //[array addObject:[NSNumber numberWithInteger:x]];
                               picImgView = [[UIImageView alloc] initWithFrame:CGRectMake(x, 479, 24, 24)];
                               }
                               }
                               
                               
                               
                               
                              /*
                               
                               //4段目
                               else if(i==12){
                               picImgView = [[UIImageView alloc] initWithFrame:CGRectMake(148, 424, 24, 24)];
                               NSLog(@"i %d",i);
                               }
                               else if(12<i && i<=16){
                               for (i = (int)[group numberOfAssets]-p-13; i <=(int)[group numberOfAssets]-p-13; i++)
                               {
                               x = 148 +24 *(i/2 + i%2)*n;
                               y = 427+(i-1)/2*5;
                               NSLog(@"y %d",y);
                               //[array addObject:[NSNumber numberWithInteger:x]];
                               // [array addObject:[NSNumber numberWithInteger:y]];
                               
                               picImgView = [[UIImageView alloc] initWithFrame:CGRectMake(x, 400, 24, 24)];
                               
                               picImgView = [[UIImageView alloc] initWithFrame:CGRectMake(x, y, 24, 24)];
                               }
                               }
                               else if(16<i && i<=18){
                               for (i = (int)[group numberOfAssets]-p-13; i <=(int)[group numberOfAssets]-p-13; i++)
                               {
                               NSLog(@"i %d",i);
                               
                               x = 148 +23 *(i/2 + i%2)*n;
                               
                               //[array addObject:[NSNumber numberWithInteger:x]];
                               picImgView = [[UIImageView alloc] initWithFrame:CGRectMake(x, 444, 24, 24)];
                               }
                               }
                               
                               else if(18<i && i<=20){
                               for (i = (int)[group numberOfAssets]-p-13; i <=(int)[group numberOfAssets]-p-13; i++){
                               NSLog(@"i %d",i);
                               
                               x = 148 +24 *(i/2 + i%2)*n;
                               
                               
                               picImgView = [[UIImageView alloc] initWithFrame:CGRectMake(x, 454, 24, 24)];
                               }
                               }
                               
                               
                               
                               
                               
                               
                               //５段目
                               else if(i==3){
                               picImgView = [[UIImageView alloc] initWithFrame:CGRectMake(148, 399, 24, 24)];
                               NSLog(@"i %d",i);
                               }
                               
                               else if(3<i && i<=7){
                               for (i = (int)[group numberOfAssets]-p-4; i <=(int)[group numberOfAssets]-p-4; i++)
                               {
                               NSLog(@"i %d",i);
                               
                               x = 148 +24 *(i/2 + i%2)*n;
                               y = 402+(i-1)/2*5;
                               NSLog(@"y %d",y);
                               //[array addObject:[NSNumber numberWithInteger:x]];
                               // [array addObject:[NSNumber numberWithInteger:y]];
                               
                               
                               picImgView = [[UIImageView alloc] initWithFrame:CGRectMake(x, y, 24, 24)];
                               }
                               }
                               
                               else if(7<i && i<=9){
                               for (i = (int)[group numberOfAssets]-p-4; i <=(int)[group numberOfAssets]-p-4; i++)
                               {
                               NSLog(@"i %d",i);
                               
                               x = 148 +23 *(i/2 + i%2)*n;
                               
                               //[array addObject:[NSNumber numberWithInteger:x]];
                               picImgView = [[UIImageView alloc] initWithFrame:CGRectMake(x, 418, 24, 24)];
                               }
                               }
                               
                               else if(9<i && i<=11){
                               for (i = (int)[group numberOfAssets]-p-4; i <=(int)[group numberOfAssets]-p-4; i++)
                               {
                               NSLog(@"i %d",i);
                               
                               x = 148 +24 *(i/2 + i%2)*n;
                               
                               //[array addObject:[NSNumber numberWithInteger:x]];
                               picImgView = [[UIImageView alloc] initWithFrame:CGRectMake(x, 428, 24, 24)];
                               }
                               }
                               */
                              /*
                               
                               [self.view addSubview:picImgView];
                               
                               UIImage *toumei = [UIImage imageNamed:@"とうめい.png"];
                               
                               UIImageView *toumeiView = [[UIImageView alloc] initWithImage:toumei];
                               
                               */
                              
                              
                              picImgView.userInteractionEnabled = YES; //タッチできるようにする
                              //TODO:image
                              picImgView.image = picImg;
                              //[picImgView addSubview:toumeiView];
                              [self.view addSubview:picImgView];
                              [self picSetting];
                              //[self.view sendSubviewToBack:picImgView];
                              [self.view sendSubviewToBack:backView];
                          }
                      }
                      /*else{
                       f = 1;
                       //NSLog(@"表示されない");
                       }
                       */
                  }
                  ];
                 
                 *stop = NO;
                 
             }
         }
     }failureBlock:^(NSError *error) {
         //NSLog(@"error: %@", error);
     }
     ];
}

-(void)picSetting
{
    /* 画像の設定 */
    picImgView.contentMode = UIViewContentModeScaleAspectFill;
    picImgView.clipsToBounds = YES;
    
    CALayer *layer = picImgView.layer;
    layer.masksToBounds = YES;
    layer.cornerRadius = 12.0f;
    
    UIImage *maruue = [UIImage imageNamed:@"sunadokei.png"];
    UIImageView *maruueView = [[UIImageView alloc] initWithImage:maruue];
    maruueView.frame = CGRectMake(45, 42, 230,490);
    
    
    [picImgView.layer setBorderWidth:1.0];
    [picImgView.layer setBorderColor:[[UIColor whiteColor] CGColor]];
    
}


//端末の向きの取得
- (void)didRotate:(NSNotification *)notification
{
    UIDeviceOrientation orientation = (UIDeviceOrientation)[[notification object] orientation];
    
    if (orientation==UIDeviceOrientationPortraitUpsideDown) {
        _orientation = @"縦(上下逆)";
        NSLog(@"がめんせんいー");
        mosaicViewController *mosaicViewViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"mosaic"];
        mosaicViewViewController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        [self presentViewController:mosaicViewViewController animated:YES completion:nil];
    }else if (orientation == UIDeviceOrientationPortrait) {
        _orientation = @"縦";
    }
}

- (BOOL)shouldAutorotate
{
    return YES;//回転許可
}

//回転する方向の指定
- (NSUInteger)supportedInterfaceOrientations
{
    //全方位回転
    //return UIInterfaceOrientationMaskAll;
    ////Portrait(HomeButtonが下)のみ
    return UIInterfaceOrientationMaskPortrait;
    
}

@end
