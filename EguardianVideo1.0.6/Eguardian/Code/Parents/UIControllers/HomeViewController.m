//
//  HomeViewController.m
//  RDOA
//
//  Created by apple on 13-3-12.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import "HomeViewController.h"
#import "Global.h"
#import <MessageUI/MessageUI.h>
#import "UIButtonEx.h"
#import "CheckWorkViewController.h"
#import "HomeWorkViewController.h"
#import "CommentViewController.h"
//#import "VideoViewController.h"
#import "NoticeViewController.h"
#import "ADScrollView.h"
#import "IMListViewController.h"
#import "SeatsAttendanceController.h"


#import "AdvertisingManager.h"
#import "FileSystemManager.h"
#import "ResourcesListManager.h"
#import "StringExpand.h"
#import "WebViewController.h"
#import "NoticeScrollView.h"
#import "ConfigManager.h"
#import "SurveillanceVdeoViewController.h"
#import "NSDictionary+Extemsions.h"

#define PromptNumberImageTag 8000
#define contentLbFont 15

@interface HomeViewController ()

@end

@implementation HomeViewController
@synthesize currentHeight;
@synthesize scrollView;
@synthesize pageControl;
@synthesize baseScrollView;
@synthesize homePageArray;
@synthesize noticeScrollView;
@synthesize readNumberList;

//************************************************************************************************************************
//************************************************************************************************************************
//广告 start

#pragma mark aurl图片地址,  index 是 对应scrollview的第几张
-(void) requestImg:(NSString *)aurl index:( int )index
{
    
    NSMutableURLRequest *request = [[[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:aurl]] autorelease];
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    [NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error)
     {
         if ( error )
             return;
         
         NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
         NSString *type = [FileSystemManager fileFormat:[httpResponse allHeaderFields]];
         NSString *dic = [FileSystemManager fileDirectory: [httpResponse allHeaderFields]];
         NSString *path = nil;
         path = Custom_File_Path([aurl stringMD5], type, dic);   //url的要md5字符串
         [FileSystemManager saveFile:data filePath:path];
         [ResourcesListManager writeResourcesPath:path];
         
         dispatch_async(dispatch_get_main_queue(),
                        ^{
                            UIImageView *adImgView = (UIImageView *)[self.baseScrollView viewWithTag:imageViewTag+index];
                            UIImage *adImage = [[UIImage alloc] initWithData:data];
                            [adImgView setImage:adImage];
                            [adImage release];
                        });
         
     }];
    [queue release];
}


#pragma mark 打开网页
-(void)openRUL
{
    NSDictionary *adObj = [self.homePageArray objectAtIndex:baseScrollViewIndex-1];
    NSString *address = [adObj objectForKey:@"url"];
    WebViewController *wc = [[WebViewController alloc] initWithURL:address];
    [self.navigationController pushViewController:wc animated:YES];
    [wc release];
}

//广告 end
//************************************************************************************************************************
//************************************************************************************************************************



- (void)dealloc
{
    [noticeScrollView stopDisplayLink];
    [noticeScrollView release];
    [homePageArray release];
    [baseScrollView release];
    [pageControl release];
    [scrollView release];
    [readNumberList release];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NotificationReadNumber object:nil];
    [super dealloc];
}

-(id) init
{
    self = [super init];
    if (self)
    {        
        imageViewTag =100;
        pageNumber = 0;
        self.controllerTag = 0;
        self.currentHeight = 0;
        self.homePageArray = [[[AdvertisingManager sharedAdvertisingManager].data objectForKey:@"ads"] objectForKey:@"home_page"];
        
        readNumberList = [[NSMutableDictionary alloc] init];
    }
    return self;
}


-(void) selectControllerWithTag:(int)atag
{
    UINavigationController *nav = rootNav;
    
//    作业
    if ( atag == 1 )
    {
        HomeWorkViewController *vc = [[HomeWorkViewController alloc] init];
        vc.readNumberDic = self.readNumberList;
        [nav pushViewController:vc animated:YES];
        [vc release];
    }
    //评语
    else if ( atag == 2 )   //book
    {

        CommentViewController *vc = [[CommentViewController alloc] init];
        vc.readNumberDic = self.readNumberList;
        [nav pushViewController:vc animated:YES];
        [vc release];
    }
//    异常考勤
    else if ( atag == 3 )   //schedule
    {
        CheckWorkViewController *vc = [[CheckWorkViewController alloc] init];
        [nav pushViewController:vc animated:YES];
        [vc release];
    }
    else if ( atag == 4 )   //schedule
    {
        SurveillanceVdeoViewController *vc = [[SurveillanceVdeoViewController alloc] init];
       [nav pushViewController:vc animated:YES];
        [vc release];
    }
    
    else if ( atag == 5 )   //通知
    {
        NoticeViewController *vc = [[NoticeViewController alloc] init];
        vc.readNumberDic = self.readNumberList;
        [nav pushViewController:vc animated:YES];
        [vc release];
        
    }
    else if ( atag == 6 )   //家校互动
    {
        IMListViewController *vc = [[IMListViewController alloc] init];
        [nav pushViewController:vc animated:YES];
        [vc release];
        
    }
    else if ( atag == 7 )   
    {
        SeatsAttendanceController *vc = [[SeatsAttendanceController alloc] init];
        [nav pushViewController:vc animated:YES];
        [vc release];
        
    }
}



-(void) footButtonAction:(UIButton *)sender
{
    
    if ( sender.tag == self.controllerTag )
        return;
    [self selectControllerWithTag:sender.tag];
}


#pragma make 切换学号
-(void)cancleAction
{
    [ConfigManager sharedConfigManager].isLeader = FALSE;
//    [[ConfigManager sharedConfigManager].wrapper loginOut];
    
    UINavigationController *nav = rootNav;
    [nav popToRootViewControllerAnimated:YES];
}



#pragma mark 添加头部
-(void)loadHeaderView
{
    UIImageView *tmpBG = [[UIImageView alloc] initWithImage: [UIImage imageNamed:@"H_HeadBG.png"] ];
    tmpBG.userInteractionEnabled = YES;
    
    {
        
        UIButton *cancleBT = [UIButton buttonWithType:UIButtonTypeCustom];
        UIImage *cancleImg = [UIImage imageNamed:@"切换账号.png"];
        [cancleBT setBackgroundImage:cancleImg forState:UIControlStateNormal];
        cancleBT.frame = CGRectMake(0, 0, cancleImg.size.width, cancleImg.size.height);
        [cancleBT addTarget:self action:@selector(cancleAction) forControlEvents:UIControlEventTouchUpInside];
        
        UIView *cancleBG = [[UIView alloc] initWithFrame:CGRectMake( tmpBG.frame.size.width - cancleImg.size.width - 20,
                                                                    (tmpBG.frame.size.height-cancleImg.size.height)/2.0,
                                                                    cancleImg.size.width, cancleImg.size.height)];
        [cancleBG addSubview:cancleBT];
        [tmpBG addSubview:cancleBG];
        [cancleBG release];
    }
    
    [baseScrollView addSubview:tmpBG];
    currentHeight = tmpBG.frame.size.height;
    [tmpBG release];
}

-(void)loadAdvertising
{
    
    UIImageView *tempADView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"首页头部广告背景.png"]];
    tempADView.userInteractionEnabled = YES;
    tempADView.frame = CGRectMake(0, currentHeight, ScreenW, tempADView.frame.size.height);
    adScrollView = [[ADScrollView alloc] initHomePageWithDelegate:self rect:CGRectMake(0, 0, tempADView.frame.size.width, tempADView.frame.size.height)];
    [tempADView addSubview:adScrollView];
    [self.baseScrollView addSubview:tempADView];
    currentHeight += tempADView.frame.size.height;
    [tempADView release];
}




-(UIView *)initCustom:(CGRect)frame imageName:(NSString *)aimageName text:(NSString *)atext buttonTag:(int)atag
{
    UIView *result = [[UIView alloc] initWithFrame:frame];
    UIImage *btImg = [UIImage imageNamed:aimageName];

    
    UIButton *btView = [UIButton buttonWithType:UIButtonTypeCustom];
    [btView setBackgroundImage:btImg forState:UIControlStateNormal];
    btView.frame = CGRectMake(0, 0, btImg.size.width, btImg.size.height);
    btView.tag = atag;

    [btView addTarget:self action:@selector(footButtonAction:) forControlEvents: UIControlEventTouchUpInside];
    [result addSubview:btView];
    
    UILabel *lable = [[UILabel alloc] initWithFrame:CGRectMake(0, btView.frame.size.height, frame.size.width, 18)];
    lable.text = atext;
    lable.backgroundColor = [UIColor clearColor];
    lable.textAlignment = UITextAlignmentCenter;
    lable.textColor = [UIColor colorWithRed:75.0/255.0 green:75.0/255.0 blue:75.0/255.0 alpha:1];
    [result addSubview:lable]; [lable release];
    
    return result;
}





#pragma mark 加载7个模块的图片
-(void)loadHomeButtons
{
    
    float origin1 = 50;
    float origin2 = 185;
    int scrollViewNumber = 2;
    
    scrollView  = [[UIScrollView alloc] initWithFrame:CGRectMake(0, currentHeight, self.view.frame.size.width, self.view.frame.size.height - currentHeight-48)];
    scrollView.contentSize = CGSizeMake(self.view.frame.size.width * scrollViewNumber, scrollView.frame.size.height);
    scrollView.delegate = self;
    scrollView.pagingEnabled = YES;
    scrollView.showsVerticalScrollIndicator = FALSE;
    scrollView.showsHorizontalScrollIndicator = FALSE;
    
    
    
    self.currentHeight += self.scrollView.frame.size.height;
    
    float tempY = 25;       //计算内部button坐标
    
    {
        
        UIImage *tempImag = [UIImage imageNamed:@"T家教互动.png"];
        CGRect tempRect = CGRectMake(origin1, tempY, tempImag.size.width, tempImag.size.height);
        UIView *tempView = [self initCustom:tempRect imageName:@"T家教互动.png" text:@"家校互动" buttonTag:6 ];
        [self.scrollView addSubview:tempView]; [tempView release];
    }
    
    {
        UIImage *tempImag = [UIImage imageNamed:@"Notice.png"];
        CGRect tempRect = CGRectMake(self.view.frame.size.width+origin1, tempY, tempImag.size.width, tempImag.size.height);
        UIView *tempView = [self initCustom:tempRect imageName:@"Notice.png" text:@"通 知" buttonTag:5];
        [self.scrollView addSubview:tempView]; [tempView release];
    }
    
    {
        UIImage *tempImag = [UIImage imageNamed:@"座位考勤.png"];
        CGRect tempRect = CGRectMake(self.view.frame.size.width+origin2, tempY, tempImag.size.width, tempImag.size.height);
//        CGRect tempRect = CGRectMake(self.view.frame.size.width+origin1, tempY, tempImag.size.width, tempImag.size.height);
        //原座位考勤 更改为异常考勤 ，原考勤删除
        UIView *tempView = [self initCustom:tempRect imageName:@"座位考勤.png" text:@"异常考勤" buttonTag:7 ];
        [self.scrollView addSubview:tempView]; [tempView release];
    }
    
    {
        
        UIImage *tempImag = [UIImage imageNamed:@"H_Video.png"];
        CGRect tempRect = CGRectMake(origin2, tempY, tempImag.size.width, tempImag.size.height);
        UIView *tempView = [self initCustom:tempRect imageName:@"H_Video.png" text:@"视频监控" buttonTag:4 ];
        [self.scrollView addSubview:tempView]; [tempView release];
        tempY += tempImag.size.height + 30;
    }
    
    
    {                
        UIImage *tempImag = [UIImage imageNamed:@"H_HomeWork.png"];
        CGRect tempRect = CGRectMake(origin1, tempY, tempImag.size.width, tempImag.size.height);
        UIView *tempView = [self initCustom:tempRect imageName:@"H_HomeWork.png" text:@"作 业" buttonTag:1 ];
        [self.scrollView addSubview:tempView]; [tempView release];
        
        
    }
    
    {
        UIImage *tempImag = [UIImage imageNamed:@"H_Comment.png"];
        CGRect tempRect = CGRectMake(origin2, tempY, tempImag.size.width, tempImag.size.height);
        UIView *tempView = [self initCustom:tempRect imageName:@"H_Comment.png" text:@"评 语" buttonTag:2 ];
        [self.scrollView addSubview:tempView]; [tempView release];
    }
    
//    {
//        UIImage *tempImag = [UIImage imageNamed:@"H_CheckWork.png"];
//        CGRect tempRect = CGRectMake(self.view.frame.size.width + origin1, tempY, tempImag.size.width, tempImag.size.height);
//        UIView *tempView = [self initCustom:tempRect imageName:@"H_CheckWork.png" text:@"考 勤" buttonTag:3];
//        [self.scrollView addSubview:tempView]; [tempView release];
//    }

    [baseScrollView addSubview:scrollView];
    
    NSInteger count = [DELEGATE.modeEngineVoip.imDBAccess getUnreadCountOfLoginName];
    NSLog(@"%d",count);
    
    {
        //底部通知
        UIImageView *bottomBGView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"T通知栏信息背景.png"]];
        bottomBGView.frame = CGRectMake(0, self.baseScrollView.frame.size.height - bottomBGView.frame.size.height,
                                        bottomBGView.frame.size.width, bottomBGView.frame.size.height);
        
//        noticeScrollView = [[NoticeScrollView alloc] initHomePageWithDelegate:self rect:CGRectMake(30, 10, 240, 20)];
        noticeScrollView = [[NoticeScrollView alloc] initHomePageWithDelegate:self rect:CGRectMake((bottomBGView.frame.size.width - 265)/2.0,
                                                                                                   (bottomBGView.frame.size.height - 25)/2.0,
                                                                                                   265, 25)];
        
        [bottomBGView addSubview:noticeScrollView];
        
        [self.baseScrollView addSubview:bottomBGView];
        [bottomBGView release];
    }
    
    pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height -  68, ScreenW, 20)];
    pageControl.numberOfPages = scrollViewNumber + self.homePageArray.count;
    [self.pageControl setCurrentPage:0];
    [self.view addSubview:pageControl];
    
    //修改 pageControl 点的颜色
    {
        CGFloat pageWidth = scrollView.frame.size.width;
        int page = floor((scrollView.contentOffset.x - pageWidth/2)/pageWidth) + 1;
        pageControl.currentPage = page;
        NSArray *subView = pageControl.subviews;     // UIPageControl的每个点
        
        for (int i = 0; i < [subView count]; i++) {
            UIImageView *dot = [subView objectAtIndex:i];
            dot.image = (pageControl.currentPage == i ? [UIImage imageNamed:@"滑动亮点.png"] : [UIImage imageNamed:@"滑动灰点.png"]);
        }
    }
    
    

}

-(void)loadView
{
    [super loadView];
//    NotificationReadNumber
     [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationReadNumber:) name:NotificationReadNumber object:nil];
}








-(void)viewWillAppear:(BOOL)animated
{
    self.navigationController.navigationBarHidden = YES;
    
    [self netWorkOfGetReadNumber];
    
    [self addPromptNumberView];
    
    if (!self.isFirst)
    {
        return;
    }
    
    self.isFirst = FALSE;
    
    
    
    {
        pageNumber = 1;
        pageNumber += self.homePageArray.count;
        baseScrollView = [[UIScrollView alloc] initWithFrame:self.view.frame];
        baseScrollView.contentSize = CGSizeMake(self.view.frame.size.width*pageNumber , scrollView.frame.size.height);
        baseScrollView.delegate = self;
        baseScrollView.pagingEnabled = YES;
        baseScrollView.showsVerticalScrollIndicator = FALSE;
        baseScrollView.showsHorizontalScrollIndicator = FALSE;
        
        
        for (int i=0; i<self.homePageArray.count; i++)
        {
            UIImageView *adImgView = [[UIImageView alloc] initWithFrame:CGRectMake(self.view.frame.size.width*(i+1), 0, self.view.frame.size.width, self.view.frame.size.height)];
            adImgView.tag = imageViewTag+i;
            adImgView.userInteractionEnabled = YES;
            [self.baseScrollView addSubview:adImgView];
            
            NSDictionary *tempAdObj = [self.homePageArray objectAtIndex:i];
            UIImage *imgData = [FileSystemManager readImage: [[tempAdObj objectForKey:@"img"] stringMD5] ];//读取本地图片
            if (imgData)
            {
                //读取本地
                adImgView.image = imgData;
            }
            else
            {
                //下载
                [self requestImg:[tempAdObj objectForKey:@"img"] index:i];
            }
            
            //单击触发事件
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            button.frame = adImgView.frame;
            [button addTarget:self action:@selector(openRUL) forControlEvents:UIControlEventTouchDown];
            [self.baseScrollView addSubview:button];
            [adImgView release];
            
        }
        [self.view addSubview:baseScrollView];
    }
    
    [self loadHeaderView];
    [self loadAdvertising];
    [self loadHomeButtons];
    
    [self addPromptNumberView];
    
}

//添加警告（提示）条数
- (void)addPromptNumberView{
    
    float originX1 = 50;
    float originY1 = 25;
    float originX2 = 185;
    float originY2 = 25 + 76 + 30;
    
    
    UIImage *image = [UIImage imageNamed:@"PromptNumber.png"];
    image = [image stretchableImageWithLeftCapWidth:image.size.width/2 topCapHeight:image.size.height/2];
    
    for (int i = 0; i < 4; i++) {
       
        UIButton *btn = (UIButton *)[scrollView viewWithTag:PromptNumberImageTag + i];
        NSInteger count = 0;;
        CGPoint center;
         //    家校互动的
        if (i == 0) {
            center.x = originX1 + 77 - 5 - 2;
            center.y = originY1 + 3;
            count = [DELEGATE.modeEngineVoip.imDBAccess getUnreadCountOfLoginName];
        }
        //通知
        else if(i == 1){
            center.x = self.view.frame.size.width + originX1 + 77 - 5;
            center.y = originY1 + 3;
        }
//        作业
        else if(i == 2){
            center.x = originX1 + 77 - 5 - 2;
            center.y = originY2 + 3;
        }
//        评语
        else if(i == 3){
            center.x = originX2 + 77 - 5 - 2;
            center.y = originY2 + 3;
        }
        
        if (readNumberList) {
            id countID = nil;
            if (i == 1) {
                countID = [readNumberList objectJudgeFullForKey:@"tongzhiweidu"];
            }else if(i == 2){
                 countID = [readNumberList objectJudgeFullForKey:@"zuoyeweidu"];
            }else if(i == 3){
                countID = [readNumberList objectJudgeFullForKey:@"pingyuweidu"]; 
            }
            if (countID) {
                count = [countID integerValue];
            }
        }
        
        if (!btn) {
            btn = [self promptBtnXImage:image Tag:PromptNumberImageTag + i];
        }
        
        if (count > 0) {
            btn.hidden = NO;
            [self fitPromptBtn:btn Center: center Count:count];
        }else {
            btn.hidden = YES;
        }
        
    }
    
    
}

- (UIButton *)promptBtnXImage:(UIImage *)image Tag:(NSInteger)tag{
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(0, 0, image.size.width, image.size.height);
    [btn setBackgroundImage:image forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btn.titleLabel setFont:[UIFont systemFontOfSize:contentLbFont]];
    btn.tag = tag;
    [scrollView addSubview:btn];
    btn.hidden = YES;
    return btn;
}

//适配btn文字的大小
- (void)fitPromptBtn:(UIButton *)btn Center:(CGPoint)center Count:(NSInteger) count{
     NSString *contentStr = nil;
    if (count > 99) {
         contentStr = @"99+";
    }else {
        contentStr = [NSString stringWithFormat:@"%d",count];
    }
   
    if (count > 10) {
        UIFont *fon = [UIFont systemFontOfSize:contentLbFont];
        CGSize size = [contentStr sizeWithFont:fon constrainedToSize:CGSizeMake(80, 240)];
        [btn setFrame:CGRectMake(btn.frame.origin.x, btn.frame.origin.y, 33 + size.width - 9, btn.frame.size.height)];
    }
    btn.center = center;
    [btn setTitle:contentStr forState:UIControlStateNormal];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
//    [DELEGATE.modeEngineVoip setModalEngineDelegate:nil];
}

-(void)action:(UIButton *)sender
{
    [self selectControllerWithTag:sender.tag];
}

//家长获取未读取信息条数
- (void)netWorkOfGetReadNumber{
    NSString *urlStr = [ConfigManager getReadNumber];;
    
    NSDictionary *dic = [[NSDictionary alloc] initWithObjectsAndKeys:NotificationReadNumber,NotificationKey, nil];
    
    //父类函数
    [self requestWithURL:urlStr UserInfo:dic Model:PartViewModel];
    
    [dic release];

}

#pragma makr 滚动scrollview时计算第几页
- (void) scrollViewDidScroll:(UIScrollView *)ascrollView
{
    if (baseScrollView == ascrollView)
    {
        CGFloat pageWidth = ascrollView.frame.size.width;
        int page = floor((ascrollView.contentOffset.x - pageWidth/2)/pageWidth) + 1;
        baseScrollViewIndex = page;
        page += currentNumber ;
        
        if (page == 0)
        {
            baseScrollView.contentOffset = CGPointMake(0, ascrollView.contentOffset.y);
            return;
        }
        
        pageControl.currentPage = page;
        NSArray *subView = pageControl.subviews;
        
        for (int i = 0; i < [subView count]; i++)
        {
            UIImageView *dot = [subView objectAtIndex:i];
            dot.image = (pageControl.currentPage == i ? [UIImage imageNamed:@"滑动亮点.png"] : [UIImage imageNamed:@"滑动灰点.png"]);
        }
    }
    else
    {
        CGFloat pageWidth = ascrollView.frame.size.width;
        int page = floor((ascrollView.contentOffset.x - pageWidth/2)/pageWidth) + 1;
        pageControl.currentPage = page;
        NSArray *subView = pageControl.subviews;     // UIPageControl的每个点
        
        for (int i = 0; i < [subView count]; i++) {
            UIImageView *dot = [subView objectAtIndex:i];
            dot.image = (pageControl.currentPage == i ? [UIImage imageNamed:@"滑动亮点.png"] : [UIImage imageNamed:@"滑动灰点.png"]);
        }
        currentNumber = page;
    }
}

#pragma mark -
#pragma mark 家长获取未读取信息条数
- (void)notificationReadNumber:(NSNotification*) notification{
    if (notification.userInfo) {
        if ([[notification.userInfo objectForKey:@"status"] isEqualToString:@"ok"]) {
            NSDictionary *tmpDic = [notification.userInfo objectJudgeFullForKey:@"content"];
            NSArray *keys = [tmpDic allKeys];
            for (NSString *key in keys) {
                [readNumberList setObject:[tmpDic objectJudgeFullForKey:key] forKey:key];
            }
        }
    }
    [self addPromptNumberView];
}

@end