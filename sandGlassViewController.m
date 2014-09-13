//
//  sandGlassViewController.m
//  PhotoGlass
//
//  Created by 梶原 一葉 on 9/3/14.
//  Copyright (c) 2014 梶原 一葉. All rights reserved.
//

#import "sandGlassViewController.h"
#import "Image.h"
#import "mosaicViewController.h"
#import "UIImage+GIF.h"

@interface sandGlassViewController ()

@end

@implementation sandGlassViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    /* --- ステータスバー消す　---*/
    if( [ UIApplication sharedApplication ].isStatusBarHidden == NO ) {
        [ UIApplication sharedApplication ].statusBarHidden = YES;
    }
    
    
    /* ---　背景画像設定 --- */
    
    back = [UIImage imageNamed:@"sandglass.png"];
    backView = [[UIImageView alloc] initWithImage:back];
    backView.frame = CGRectMake(0, 0, 320, 568);
    
    
    /* ---　背景画像設定 --- */
    
    back = [UIImage imageNamed:@"back.png"];
    
    backView = [[UIImageView alloc] initWithImage:back];
    backView.frame = CGRectMake(0, 0, 320, 568);
    
    suna = [UIImage imageNamed:@"sunadokei.png"];
    sunaView = [[UIImageView alloc] initWithImage:suna];
    sunaView.frame = CGRectMake(45, 42, 230,490);
    
    upsand = [UIImage imageNamed:@"kiiroSuna.png"];
    upsandView = [[UIImageView alloc] initWithImage:upsand];
    upsandView.frame = CGRectMake(58, 141, 200, 144);
    
    
    //gifアニメーション
    UIImage* sunaImage = [UIImage animatedGIFNamed:@"sand"];
    sunaImageView = [[UIImageView alloc] initWithImage:sunaImage];
    sunaImageView.frame = CGRectMake(158, 284, 5, 128);
    
    //    UIImage* sunaupImage = [UIImage animatedGIFNamed:@"sunaup"];
    //    sunaupImageView = [[UIImageView alloc] initWithImage:sunaupImage];
    //    sunaupImageView.frame = CGRectMake(48, 100, 220, 189);
    
    
    [self.view addSubview:backView];
    [self.view addSubview:sunaView];
    [self.view addSubview:sunaImageView];
    [self.view addSubview:upsandView];
    //    [self.view addSubview:sunaupImageView];
    
    
    AlbumSandName = @"Mosaic";
    
    //端末回転通知の開始
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didRotate:)
                                                 name:UIDeviceOrientationDidChangeNotification
                                               object:nil];
    
    [self.view addSubview:backView];
    
    //UIImagePickerController
    _pickerController =[[UIImagePickerController alloc] init];
    _pickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
    _pickerController.delegate = self;
    _pickerController.allowsEditing = YES;
    
    //ALAssetLibraryのインスタン作成
    _library = [[ALAssetsLibrary alloc] init];
    _AlbumName = @"PhotoGlass";
    _albumWasFound = FALSE;
    
    //アルバムを検索してなかったら新規作成、あったらアルバムのURLを保持
    [_library enumerateGroupsWithTypes:ALAssetsGroupAlbum
                            usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
                                
                                if (group) {
                                    
                                    NSLog(@"作成したよ");
                                    if ([_AlbumName compare:[group valueForProperty:ALAssetsGroupPropertyName]] == NSOrderedSame) {
                                        
                                        //URLをクラスインスタンスに保持
                                        _groupURL = [group valueForProperty:ALAssetsGroupPropertyURL];
                                        _albumWasFound = TRUE;
                                        
                                        //アルバムがない場合は新規作成
                                    }else if (_albumWasFound==FALSE) {
                                        
                                        ALAssetsLibraryGroupResultBlock resultBlock = ^(ALAssetsGroup *group) {
                                            _groupURL = [group valueForProperty:ALAssetsGroupPropertyURL];
                                        };
                                        
                                        //新しいアルバムを作成
                                        [_library addAssetsGroupAlbumWithName:_AlbumName
                                                                  resultBlock:resultBlock
                                                                 failureBlock: nil];
                                        
                                        _albumWasFound = TRUE;

                                        
                                        
                                    }
                                }
                                
                            } failureBlock:nil];
    
    

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
    
    
    /* --- 写真 --- */
    ALAssetsLibrary *assetsLibrary = [[ALAssetsLibrary alloc] init];
    
    [assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos
                                 usingBlock:^(ALAssetsGroup *group, BOOL *stop)
     {
         
         //NSLog(@"number %d",(int)[group numberOfAssets]);
         //NSLog(@"group is %@",group);
         
         
         if ([[group valueForProperty:ALAssetsGroupPropertyName] isEqualToString:@"Camera Roll"])
         {
             [group setAssetsFilter:[ALAssetsFilter allPhotos]]; //全部の写真とってくる(movieはない)
             
             
             //__block int f = 0;
             //NSMutableArray *array = [[NSMutableArray alloc] init];
             
             
             for(int p = (int)[group numberOfAssets]-1; p >=(int)[group numberOfAssets]-42 ; p--)
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
                              
                              
                              
                              ALAssetRepresentation *assetRespresentation = [result defaultRepresentation];
                              
                              UIImage *picImg = [UIImage imageWithCGImage:[assetRespresentation fullScreenImage]]; //フルスクリーンサイズの画像をpicImgにいれる
                              
                              
                              
                              int i = (int)[group numberOfAssets]-p-1; //最新の写真が0
                              int x = 0; //x座標
                              int y = 0;
                              
                              
                              
                              double n = pow(-1, i);  //-1をi乗した数をresultにいれる
                              
                              if(i==35){
                                  picImgView = [[UIImageView alloc] initWithFrame:CGRectMake(148, 505, 24, 24)];
                                  
                                  NSLog(@"i %d",i);
                              }
                              
                              else if(35<i && i<=39){
                                  for (i = (int)[group numberOfAssets]-p-36; i <=(int)[group numberOfAssets]-p-36; i++)
                                  {
                                      NSLog(@"i %d",i);
                                      
                                      x = 148 +24 *(i/2 + i%2)*n;
                                      
                                      //[array addObject:[NSNumber numberWithInteger:x]];
                                      
                                      
                                      picImgView = [[UIImageView alloc] initWithFrame:CGRectMake(x, 505, 24, 24)];
                                  }
                              }
                              
                              else if(39<i && i<=41){
                                  for (i = (int)[group numberOfAssets]-p-36; i <=(int)[group numberOfAssets]-p-36; i++)
                                  {
                                      NSLog(@"i %d",i);
                                      
                                      x = 148 +24 *(i/2 + i%2)*n;
                                      
                                      //[array addObject:[NSNumber numberWithInteger:x]];
                                      
                                      picImgView = [[UIImageView alloc] initWithFrame:CGRectMake(x, 495, 24, 24)];
                                  }
                              }
                              
                              
                              
                              
                              
                              
                              
                              //2段目
                              
                              else if(i==30){
                                  picImgView = [[UIImageView alloc] initWithFrame:CGRectMake(148, 475, 24, 24)];
                                  NSLog(@"i %d",i);
                              }
                              
                              else if(30<i && i<=34){
                                  for (i = (int)[group numberOfAssets]-p-31; i <=(int)[group numberOfAssets]-p-31; i++)
                                  {
                                      NSLog(@"i %d",i);
                                      
                                      x = 148 +24 *(i/2 + i%2)*n;
                                      y = 478+(i-1)/2*3;
                                      
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
                              
                              
                              [self.view addSubview:picImgView];
                              
                              picImgView.userInteractionEnabled = YES; //タッチできるようにする
                              //TODO:image
                              picImgView.image = picImg;
                              
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
    return YES;                                           //回転許可
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
