/*
 *  Copyright (c) 2013 The CCP project authors. All Rights Reserved.
 *
 *  Use of this source code is governed by a Beijing Speedtong Information Technology Co.,Ltd license
 *  that can be found in the LICENSE file in the root of the web site.
 *
 *                    http://www.cloopen.com
 *
 *  An additional intellectual property rights grant can be found
 *  in the file PATENTS.  All contributing project authors may
 *  be found in the AUTHORS file in the root of the source tree.
 */

#import "GroupInfoViewController.h"
#import "IMMemberGridViewCell.h"
#import "UIselectContactsViewController.h"
#import "SendIMViewController.h"
#import "EditGroupCardViewController.h"
#import "GroupCardInfoViewController.h"
#import "GradeClassViewController.h"
#import "ConfigManager.h"
#import "Global.h"
#import "IntercomingViewController.h"

#define TAG_TABLEVIEW_GROUPCARD   3000

@interface GroupInfoViewController ()
{
    BOOL isOwnGroup;
    NSInteger groupPermission;
    BOOL isMyJoinGroup;
    UITextField *myTextField;
}
@property (nonatomic, retain) MMGridView *myGridView;
@property (nonatomic, retain) NSMutableArray *groupMemberArr;
@property (nonatomic, retain) UIView *sectionTwoView;

- (void)createTableViewWithTag:(NSInteger) tag;
@end

@implementation GroupInfoViewController

@synthesize groupInfo;
@synthesize myGridView;
@synthesize groupMemberArr;
@synthesize titleImgView;
@synthesize accountsArray;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if (self)
    {
        self.title = @"群成员";
    }
    return self;
}
- (id)initWithGroupId:(NSString*)groupid andIsMyJoin:(BOOL)isJoin andPermission:(NSInteger)permission
{
    self = [super init];
    
    if (self)
    {
        self.groupInfo = [[[IMGroup alloc] init] autorelease];
        isMyJoinGroup = isJoin;
        groupPermission = permission;
        self.groupInfo.groupId = groupid;
    }
    return self;
}

//返回并保存内容
-(void)popToPreView
{
    if (isOwnGroup && (![declaredTextField.text isEqualToString:groupInfo.declared]))
    {
         [self.modelEngineVoip modifyGroupWithGroupId:self.groupInfo.groupId andName:self.groupInfo.name andDeclared:declaredTextField.text andPermission:groupInfo.permission];
    }
    [super popToPreView];
}

//解散和退出群组时返回内容
- (void)quitToBackView
{
    NSArray* controllersArry = self.navigationController.viewControllers;
    if (controllersArry.count>2)
    {
        UIViewController *view = [controllersArry objectAtIndex:controllersArry.count-2];
        if ([view isKindOfClass:[SendIMViewController class]])
        {
            [self.navigationController popToViewController:[controllersArry objectAtIndex:controllersArry.count-3] animated:YES];
            return;
        }
    }
    [super popToPreView];
}
- (void)loadView
{
    isOwnGroup = NO;
//    UIBarButtonItem *leftBarItem = [[UIBarButtonItem alloc] initWithCustomView:[CommonTools navigationItemBtnInitWithTitle:@"返回" target:self action:@selector(popToPreView)]];
//    self.navigationItem.leftBarButtonItem = leftBarItem;
//    [leftBarItem release];
    //定制返回按钮
    {
        UIImage* image= [UIImage imageNamed:@"NavBack.png"];
        CGRect frame_1= CGRectMake(0, 0, image.size.width, image.size.height);
        UIButton* backButton= [[UIButton alloc] initWithFrame:frame_1];
        [backButton setBackgroundImage:image forState:UIControlStateNormal];
        [backButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [backButton addTarget:self action:@selector(popToPreView) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem* someBarButtonItem= [[UIBarButtonItem alloc] initWithCustomView:backButton];
        [self.navigationItem setLeftBarButtonItem:someBarButtonItem];
        [someBarButtonItem release];
        [backButton release];
    }

    
//    self.title = @"群组名称";
    
    UIBarButtonItem *clearMessage=[[UIBarButtonItem alloc] initWithCustomView:[CommonTools navigationItemBtnInitWithTitle:@"添加" target:self action:@selector(addInfo)]];
    self.navigationItem.rightBarButtonItem = clearMessage;
    [clearMessage release];

    self.groupMemberArr = [[[NSMutableArray alloc] init] autorelease];

    UIView* mainview = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]];
    mainview.backgroundColor = VIEW_BACKGROUND_COLOR_WHITE;
    self.view = mainview;
    [mainview release];
    
    
    CGRect frame = [[UIScreen mainScreen] applicationFrame];
    frame.origin.y= 0;
    selfview = [[UIView alloc] initWithFrame:frame];
    selfview.backgroundColor = VIEW_BACKGROUND_COLOR_WHITE;
    [self.view addSubview:selfview];
    [selfview release];
    
//    [self createSectionViewWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 23.0f)
//                            andTitle:@"群公告"
//                              inView:selfview];
    
//    declaredTextField = [[UITextField alloc] initWithFrame:CGRectMake(10.0f, 33.0f, 300.0f, 45.0f)];
//    [selfview addSubview:declaredTextField];
//    declaredTextField.enabled = NO;
//    [declaredTextField release];
    
    [self createSectionTwoViewWithInView:selfview];
    self.modelEngineVoip.UIDelegate = self;
    if (isMyJoinGroup)
    {
        [self setMyGroup];
    }
    
    [self.view bringSubviewToFront:selfview];
}

//添加成员
- (void)addInfo{
    GradeClassViewController *nc = [[GradeClassViewController alloc] initWithDelegate:self Select:NO ];
    [self.navigationController pushViewController:nc animated:YES];
    [nc release];
}

-(void)setMyGroup
{
//    UIView * titleView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 145.0f, 44.0f)];
//    UIImageView *titleImg = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 8.0f, 145.0f, 28.0f)];
//    self.titleImgView = titleImg;
//    titleImg.image = [UIImage imageNamed:@"title_button_01.png"];
//    [titleView addSubview:titleImg];
//    [titleImg release];
    
//    UIButton *titleLeftBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//    titleLeftBtn.frame = CGRectMake(0.0f, 8.0f, 72.0f, 28.0f);
//    titleLeftBtn.titleLabel.font = [UIFont systemFontOfSize:13.0f];
//    [titleLeftBtn addTarget:self action:@selector(showGroupInfo) forControlEvents:UIControlEventTouchUpInside];
//    [titleLeftBtn setTitle:@"群成员" forState:UIControlStateNormal];
//    [titleView addSubview:titleLeftBtn];
//    
//    UIButton *titleRightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//    titleRightBtn.titleLabel.font = [UIFont systemFontOfSize:13.0f];
//    titleRightBtn.frame = CGRectMake(73.0f, 8.0f, 72.0f, 28);
//    [titleRightBtn addTarget:self action:@selector(showGroupCard) forControlEvents:UIControlEventTouchUpInside];
//    [titleRightBtn setTitle:@"群名片" forState:UIControlStateNormal];
//    [titleView addSubview:titleRightBtn];
    
//    self.navigationItem.titleView = titleView;
//    [titleView release];
    self.title = @"群成员";
    [self createTableViewWithTag:TAG_TABLEVIEW_GROUPCARD];
    [self.modelEngineVoip queryGroupCardWithOther:self.modelEngineVoip.voipAccount andBelong:groupInfo.groupId];
}

-(void) save
{
    [self displayProgressingView];
    [self.modelEngineVoip modifyGroupCard:self.groupCard];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.modelEngineVoip.UIDelegate = self;
    [self.modelEngineVoip queryGroupDetailWithGroupId:self.groupInfo.groupId];
    if (isMyJoinGroup)
    {
        [self.modelEngineVoip queryMemberWithGroupId:self.groupInfo.groupId];
    }
    UITableView* tmpview = (UITableView*) [self.view viewWithTag:TAG_TABLEVIEW_GROUPCARD];
    [tmpview reloadData];

}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationGroupInfoViewController:) name:NotificationGroupInfoViewController object:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    self.groupInfo = nil;
    self.groupCard = nil;
    self.groupMemberArr = nil;
    self.myGridView = nil;
    self.sectionTwoView = nil;
    self.titleImgView = nil;
    self.accountsArray = nil;
     [[NSNotificationCenter defaultCenter] removeObserver:self name:NotificationGroupInfoViewController object:nil];
    [super dealloc];
}
#pragma mark - custom methods

-(void)showGroupInfo
{
    self.titleImgView.image = [UIImage imageNamed:@"title_button_01.png"];
    self.navigationItem.rightBarButtonItem = nil;
    [self.view bringSubviewToFront:selfview];
}

-(void)showGroupCard
{
    self.titleImgView.image = [UIImage imageNamed:@"title_button_02.png"];
    UIView* tmpview = [self.view viewWithTag:TAG_TABLEVIEW_GROUPCARD];
    [self.view bringSubviewToFront:tmpview];
    
    UIBarButtonItem *clearMessage=[[UIBarButtonItem alloc] initWithCustomView:[CommonTools navigationItemBtnInitWithTitle:@"保存" target:self action:@selector(save)]];
    self.navigationItem.rightBarButtonItem = clearMessage;
    [clearMessage release];
}

#pragma mark - private methods
//创建显示页面内容
- (void)createSectionTwoViewWithInView:(UIView*) parView
{
    if (isMyJoinGroup)
    {
        if (self.sectionTwoView != nil)
        {
            if (self.sectionTwoView.tag == 501)
            {
                [self.sectionTwoView removeFromSuperview];
                self.sectionTwoView = nil;
            }
            else if(self.sectionTwoView.tag == 500)
            {
                return;
            }
        }
        
        CGFloat viewHeight = [[UIScreen mainScreen] applicationFrame].size.height - 44.0f;
        UIView *tmpview = [[UIView alloc] initWithFrame:CGRectMake(0, 0.0f, 320.0f, viewHeight)];
        tmpview.tag = 500;
        self.sectionTwoView = tmpview;
        self.sectionTwoView.backgroundColor = VIEW_BACKGROUND_COLOR_WHITE;
        
        [self createSectionViewWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 23.0f)
                                andTitle:@"群成员"
                                  inView:self.sectionTwoView];
        
        MMGridView *gridView = [[MMGridView alloc] initWithFrame:CGRectMake(0.0f, 23.0f, 320.0f, viewHeight - 23.0f - 40.0f)];
        self.myGridView = gridView;
        gridView.cellMargin = 8.0f;
        gridView.numberOfRows = gridView.frame.size.height/100.0f;
        gridView.numberOfColumns = 4;
        gridView.layoutStyle = VerticalLayout;
        gridView.delegate = self;
        gridView.dataSource = self;
        [self.sectionTwoView addSubview:gridView];
        [gridView release];
        
        UIButton *leftBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        leftBtn.tag = 200;
        leftBtn.frame = CGRectMake(17.0f, viewHeight - 40.0f, 126.0f, 37.0f);
        [leftBtn setBackgroundImage:[UIImage imageNamed:@"groups_button01_off.png"] forState:UIControlStateNormal];
        [leftBtn setBackgroundImage:[UIImage imageNamed:@"groups_button01_on.png"] forState:UIControlStateHighlighted];
        [leftBtn addTarget:self action:@selector(buttomBtnEvent:) forControlEvents:UIControlEventTouchUpInside];
        [leftBtn setTitle:@"清除聊天记录" forState:UIControlStateNormal];
        [leftBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self.sectionTwoView addSubview:leftBtn];
        
        CGRect frame = leftBtn.frame;
        frame.origin.x = 160.0f+17.0f;
        rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        rightBtn.tag = 201;
        [rightBtn setBackgroundImage:[UIImage imageNamed:@"groups_button02_off.png"] forState:UIControlStateNormal];
        [rightBtn setBackgroundImage:[UIImage imageNamed:@"groups_button02_on.png"] forState:UIControlStateHighlighted];
        [rightBtn addTarget:self action:@selector(buttomBtnEvent:) forControlEvents:UIControlEventTouchUpInside];
        [rightBtn setTitle:@"退出该群组" forState:UIControlStateNormal];
        [rightBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        rightBtn.frame = frame;
        [self.sectionTwoView addSubview:rightBtn];

        [parView addSubview:tmpview];
        [tmpview release];
    }
    else
    {
        if (self.sectionTwoView != nil)
        {
            if (self.sectionTwoView.tag == 500)
            {
                [self.sectionTwoView removeFromSuperview];
                self.sectionTwoView = nil;
            }
            else if(self.sectionTwoView.tag == 501)
            {
                return;
            }
        }
        
        CGFloat viewHeight = [[UIScreen mainScreen] applicationFrame].size.height;
        UIView *tmpview = [[UIView alloc] initWithFrame:CGRectMake(0, 88.0f, 320.0f, viewHeight-88.0f-44.0f)];
        tmpview.tag = 501;
        self.sectionTwoView = tmpview;
        self.sectionTwoView.backgroundColor = VIEW_BACKGROUND_COLOR_WHITE;
        
        [self createSectionViewWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 23.0f)
                                andTitle:@"申请加入群组"
                                  inView:self.sectionTwoView];
        
        UIButton *joinBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        joinBtn.frame = CGRectMake(80.0f, 100.0f, 160.0f, 60.0f);
        [joinBtn addTarget:self action:@selector(joinBtnEvent:) forControlEvents:UIControlEventTouchUpInside];
        [joinBtn setTitle:@"申请加入群组" forState:UIControlStateNormal];
        [joinBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [joinBtn setBackgroundImage:[[UIImage imageNamed:@"groups_button01_off.png"] stretchableImageWithLeftCapWidth:70.0f topCapHeight:15.0f] forState:UIControlStateNormal];
        [joinBtn setBackgroundImage:[[UIImage imageNamed:@"groups_button01_on.png"] stretchableImageWithLeftCapWidth:70.0f topCapHeight:15.0f] forState:UIControlStateHighlighted];
        
        [self.sectionTwoView addSubview:joinBtn];
        
        [parView addSubview:tmpview];
        [tmpview release];
    }
}
//创建显示页头
- (void)createSectionViewWithFrame:(CGRect)frame andTitle:(NSString *)title inView:(UIView*)parView
{
    UIView *headView = [[UIView alloc] initWithFrame:frame];
    
    UIImageView *image = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"list_bg.png"]];
    [headView addSubview:image];
    [image release];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(12.0f, 0.0f, 300, 23.0f)];
    [headView addSubview:label];
    label.font = [UIFont systemFontOfSize:13.0f];
    label.backgroundColor = [UIColor clearColor];
    label.text = title;
    label.textColor = [UIColor whiteColor];
    [label release];
    
    [parView addSubview:headView];
    [headView release];
}

- (void)createTableViewWithTag:(NSInteger) tag
{
    UIView* view = [self.view viewWithTag:tag];
    if (view == nil)
    {
        UITableView *tableView = nil;
        
        if (IPHONE5)
        {
            tableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 578.f-20.f)
                                                     style:UITableViewStylePlain];;
        }
        else
        {
            tableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 460.0f)
                                                     style:UITableViewStylePlain];
        }
        
        tableView.autoresizingMask = (UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight);
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        tableView.delegate = self;
        tableView.dataSource = self;
        tableView.backgroundColor = VIEW_BACKGROUND_COLOR_WHITE;
        tableView.tableFooterView = [[[UIView alloc] init] autorelease];
        tableView.tag = tag;
        [self.view addSubview:tableView];
        [tableView release];
    }
}

- (void)joinBtnEvent:(id)sender
{
    //该群组设置了身份验证，请输入加入理由
    UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"\n"
                                                 message:nil
                                                delegate:self
                                       cancelButtonTitle:@"取消"
                                       otherButtonTitles:@"确定",nil];
    alert.tag = 9999;
    [self willPresentAlertView:alert ];
    UILabel *lbl=[[UILabel alloc]initWithFrame:CGRectMake(30,-70,290,40)];
    [lbl setText:@"                 加入群组"];
    lbl.numberOfLines = 0;
    [lbl setBackgroundColor:[UIColor clearColor]];
    [lbl setTextColor:[UIColor whiteColor]];
    [alert addSubview:lbl];
    [lbl release];
    
    UILabel *ulbl=[[UILabel alloc]initWithFrame:CGRectMake(5,-50,270,40)];
    if (groupPermission==0)
    {
        [ulbl setText:@"该群组可直接加入"];
    }
    else
    {
        [ulbl setText:@"该群组需要管理员验证"];
    }
    ulbl.numberOfLines = 0;
    ulbl.lineBreakMode = UILineBreakModeCharacterWrap;
    ulbl.font = [UIFont systemFontOfSize:14];
    [ulbl setBackgroundColor:[UIColor clearColor]];
    [ulbl setTextColor:[UIColor whiteColor]];
    [alert addSubview:ulbl];
    [ulbl release];
    
    myTextField = [[[UITextField alloc] initWithFrame:CGRectMake(20.0, 0, 240.0, 30.0)] autorelease];
    myTextField.tag = 9999;
    myTextField.placeholder = @"请输入加入理由";
    myTextField.borderStyle = UITextBorderStyleRoundedRect;
    [myTextField setBackgroundColor:[UIColor whiteColor]];
    myTextField.delegate = self;
    [alert addSubview:myTextField];
    [alert show];
    [alert release];
    [myTextField becomeFirstResponder];
}

- (void)buttomBtnEvent:(id)sender
{
    UIButton *btn = (UIButton*)sender;
    if (btn.tag == 200)
    {
        //leftbtn响应
         NSString* strMsg = [NSString stringWithFormat:@"确认要%@吗？",btn.titleLabel.text];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:btn.titleLabel.text
                                                        message:strMsg
                                                       delegate:nil
                                              cancelButtonTitle:@"取消"
                                              otherButtonTitles:@"确认",nil];
        alert.tag = 100;
        alert.delegate = self;
        [alert show];
        [alert release];
    }
    else if(btn.tag == 201)
    {
        //rightbtn响应
        NSString* strMsg = [NSString stringWithFormat:@"确认要%@吗？",btn.titleLabel.text];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:btn.titleLabel.text
                                                        message:strMsg
                                                       delegate:nil
                                              cancelButtonTitle:@"取消"
                                              otherButtonTitles:@"确认",nil];
        alert.tag = 101;
        alert.delegate = self;
        [alert show];
        [alert release];
    }
}

#pragma mark - UITextFieldDelegate
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (textField.tag == 9999)
    {
        if (range.length == 1)
        {
            return YES;
        }
        
        NSMutableString *text = [[myTextField.text mutableCopy] autorelease];
        [text replaceCharactersInRange:range withString:string];
        return [text length] <= 50;
    }
    return YES;
}

- (void)willPresentAlertView:(UIAlertView *)openURLAlert
{
    if (openURLAlert.tag == 9999)
    {
        [openURLAlert setBounds:CGRectMake(-10, -80, 300, 200 )];
    }
}

#pragma - MMGridViewDataSource

- (NSInteger)numberOfCellsInGridView:(MMGridView *)gridView
{
    NSInteger count = self.groupMemberArr.count;
    if (isOwnGroup)
    {
        count += 1;
    }
    return count ;
}

- (MMGridViewCell *)gridView:(MMGridView *)gridView cellAtIndex:(NSUInteger)index
{
    IMMemberGridViewCell *cell = [[[IMMemberGridViewCell alloc] initWithFrame:CGRectNull] autorelease];
    if (index == self.groupMemberArr.count)
    {
        cell.backgroundView.image = [UIImage imageNamed:@"add_icon.png"];
        cell.textLabel.text = @"添加";
    }
    else
    {
        NSMutableString *member = [self.groupMemberArr objectAtIndex:index];        
        NSArray *infos = [member componentsSeparatedByString:@";&;"];
        NSString *tmp = [infos objectAtIndex:0];
 
        NSString *isBan = @"";
        if (infos.count>1)
        {
            NSString *info1 = [infos objectAtIndex:1];
            if ([info1 isEqualToString:@"1"])
            {
                isBan = @"[禁言]";
            }
        }
        
        NSArray* arrTmp = [tmp componentsSeparatedByString:@"|&|"];
        NSString *voip = [arrTmp objectAtIndex:0];
        NSString *display = nil;
        
        if (arrTmp.count > 1)
        {
             display = [arrTmp objectAtIndex:1];
        }
        if (display.length >0 )
            cell.textLabel.text = display;
        else
            cell.textLabel.text = [NSString stringWithFormat:@"%@%@",voip.length>4?([voip substringFromIndex:voip.length-4]):voip, isBan];
        cell.backgroundView.image = [UIImage imageNamed:@"list_icon03.png"];
    }
    return cell;
}

#pragma - MMGridViewDelegate

- (void)gridView:(MMGridView *)gridView didSelectCell:(MMGridViewCell *)cell atIndex:(NSUInteger)index
{
    if (isOwnGroup)
    {
        if (index == self.groupMemberArr.count)
        {
            //邀请成员联系人页面
//            UIselectContactsViewController* selectView = [[UIselectContactsViewController alloc] initWithAccountList:self.modelEngineVoip.accountArray andSelectType:ESelectViewType_GroupMemberView];
//            selectView.backView = self;
//            selectView.groupId = self.groupInfo.groupId;
//            [self.navigationController pushViewController:selectView animated:YES];
//            [selectView release];
            GradeClassViewController *nc = [[GradeClassViewController alloc] initWithDelegate:self Select:NO ];
            [self.navigationController pushViewController:nc animated:YES];
            [nc release];

        }
        else
        {
            selectIndex = index;
            NSMutableString* member = [self.groupMemberArr objectAtIndex:index];
            NSArray *infos = [member componentsSeparatedByString:@";&;"];
            NSString *tmp = [infos objectAtIndex:0];
            NSArray* arrTmp = [tmp componentsSeparatedByString:@"|&|"];
            NSString *voip = [arrTmp objectAtIndex:0];
            if ([self.modelEngineVoip.voipAccount isEqualToString:voip])
            {
                [self showGroupCard];
                return;
            }
            UIActionSheet *menu = [[UIActionSheet alloc]
                    initWithTitle: @"选择账号"
                    delegate:self
                    cancelButtonTitle:nil
                    destructiveButtonTitle:nil
                    otherButtonTitles:nil];

//            NSString *isBan = [infos objectAtIndex:1];
//            if ([isBan isEqualToString:@"0"])
//            {
//                [menu addButtonWithTitle:@"禁言"];
//            }
//            else
//            {
//                [menu addButtonWithTitle:@"解除禁言"];
//            }
            
            [menu addButtonWithTitle:@"踢出该群"];
//            [menu addButtonWithTitle:@"查看成员"];
            [menu addButtonWithTitle:@"取消"];
            [menu setCancelButtonIndex:1];
            [menu showInView:selfview.window];
            [menu release];
        }
    }
    else
    {
        NSMutableString* member = [self.groupMemberArr objectAtIndex:index];
        NSArray *infos = [member componentsSeparatedByString:@";&;"];
        NSString *tmp = [infos objectAtIndex:0];
        NSArray* arrTmp = [tmp componentsSeparatedByString:@"|&|"];
        NSString *voip = [arrTmp objectAtIndex:0];
        if ([self.modelEngineVoip.voipAccount isEqualToString:voip])
        {
            [self showGroupCard];
            return;
        }
        [self showOtherGroupCardWithVoipAccount:voip andGroupId:self.groupInfo.groupId];
    }
}
-(BOOL)canLoadMoreForGrid
{
    [declaredTextField resignFirstResponder];
    return NO;
}

#pragma mark - UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if ( buttonIndex == actionSheet.cancelButtonIndex || self.groupMemberArr.count <= selectIndex)
    {
        return;
    }
    
    NSMutableString *member = [self.groupMemberArr objectAtIndex:selectIndex];
    NSArray *infos = [member componentsSeparatedByString:@";&;"];
    NSString *tmp = [infos objectAtIndex:0];
    NSArray* arrTmp = [tmp componentsSeparatedByString:@"|&|"];
    NSString *voip = [arrTmp objectAtIndex:0];
//    if (buttonIndex == 0)
//    {
//        [self displayProgressingView];
//        //0：可发言（默认）1：禁言 2：对组内所有成员禁言
//        NSInteger isBan = 1;
//        if (infos.count>1)
//        {
//            NSString *info1 = [infos objectAtIndex:1];
//            if ([info1 isEqualToString:@"1"])
//            {
//                //1代表被禁言了 要解除禁言
//                isBan = 0;
//            }
//        }
//        [self.modelEngineVoip forbidSpeakWithGroupId:self.groupInfo.groupId andMember:voip andOperation:isBan];
//    }
//    else
    if(buttonIndex == 0)
    {
        [self displayProgressingView];
        //踢出该群
        [self.modelEngineVoip deleteGroupMemberWithGroupId:self.groupInfo.groupId andMembers:[NSArray arrayWithObject:voip]];
    }
//    else if(buttonIndex == 0)
//    {
//        [self showOtherGroupCardWithVoipAccount:voip andGroupId:self.groupInfo.groupId];
//    }
}

-(void) showOtherGroupCardWithVoipAccount :(NSString*) voip andGroupId:(NSString*) groupId
{
    GroupCardInfoViewController* view = [[GroupCardInfoViewController alloc] initWithVoip:voip andGroupId:groupId andIsOwner:isOwnGroup];
    [self.navigationController pushViewController: view animated:YES];
    [view release];
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if ( buttonIndex == alertView.cancelButtonIndex)
    {
        return;
    }
    
    if (alertView.tag == 100)
    {
        //leftbtn响应的弹出框 清空聊天记录
        [self.modelEngineVoip.imDBAccess deleteIMOfSomeone:self.groupInfo.groupId];
        return;
    }
    [self displayProgressingView];
    if (alertView.tag == 101)
    {
        //rigthbtn响应的弹出框//退出或者解散群组
        if (isOwnGroup)
        {
            //解散
            [self.modelEngineVoip deleteGroupWithGroupId:self.groupInfo.groupId];
        }
        else
        {
            //退出
            [self.modelEngineVoip logoutGroupWithGroupId:self.groupInfo.groupId];            
        }
    }
    else  if (alertView.tag == 9999)
    {
        if (buttonIndex == 1)
        {
            NSString *declared = myTextField.text.length>0?myTextField.text:@"";
            [self displayProgressingView];
            [self.modelEngineVoip joinGroupWithGroupId:self.groupInfo.groupId  andDeclared:declared];
        }
    }
}
#pragma mark - 各种回调
-(void)onGroupQueryGroupWithReason:(NSInteger)reason andGroup:(IMGroup *)group
{
    if (reason == 0)
    {
//        self.title = group.name;
        self.groupInfo = group;
        self.groupInfo.permission = groupPermission;
        
        declaredTextField.text = group.declared;
        if (isMyJoinGroup)
        {
            if ([group.owner isEqualToString:self.modelEngineVoip.voipAccount])
            {
                isOwnGroup = YES;
                declaredTextField.enabled = YES;
                declaredTextField.borderStyle = UITextBorderStyleRoundedRect;
                [rightBtn setTitle:@"解散该群组" forState:UIControlStateNormal];
                [self.myGridView reloadData];
            }
            else
            {
                declaredTextField.enabled = NO;
                [rightBtn setTitle:@"退出该群组" forState:UIControlStateNormal];
            }
        }
    }
}


-(void)onMemberQueryMemberWithReason:(NSInteger)reason andMembers:(NSArray *)members
{
    if (reason == 0)
    {
        [self.groupMemberArr removeAllObjects];
        [self.groupMemberArr addObjectsFromArray:members];
        [self.myGridView reloadData];
    }
}

-(void)onGroupDeleteGroupMemberWithReason:(NSInteger)reason//删除成员
{
    [self dismissProgressingView];
    if (reason == 0)
    {
        [self.groupMemberArr removeObjectAtIndex:selectIndex];
        [self.myGridView reloadData];
    }
}

-(void)onGroupDeleteGroupWithReason:(NSInteger)reason//解散
{
    [self dismissProgressingView];
    if (reason == 0)
    {
        [self quitToBackView];
    }
    else
    {
        [self  popPromptViewWithMsg:@"解散群组失败，请稍后再试！" AndFrame:CGRectMake(0, 160, 320, 30)];
    }
}

-(void)onGroupLogoutGroupWithReason:(NSInteger)reason//退出
{
    [self dismissProgressingView];
    if (reason == 0)
    {
        [self quitToBackView];
    }
    else
    {
        [self  popPromptViewWithMsg:@"退出群组失败，请稍后再试！" AndFrame:CGRectMake(0, 160, 320, 30)];
    }
}

-(void)onGroupJoinGroupWithReason:(NSInteger)reason
{
    [self dismissProgressingView];
    if (reason == 0)
    {
        if (groupPermission == 0)
        {
            isMyJoinGroup = YES;
            [self createSectionTwoViewWithInView:selfview];
            [self setMyGroup];
            [self.view bringSubviewToFront:selfview];
            [self.modelEngineVoip queryMemberWithGroupId:self.groupInfo.groupId];
        }
        else
        {
            [self  popPromptViewWithMsg:@"已发送加入请求，请等待管理员验证！" AndFrame:CGRectMake(0, 160, 320, 30)];
        }
    }
    else
    {
        [self  popPromptViewWithMsg:@"申请加入失败，请稍后再试！" AndFrame:CGRectMake(0, 160, 320, 30)];
    }
}

//管理员对用户禁言
- (void)onForbidSpeakWithReason: (NSInteger) reason
{
    [self dismissProgressingView];
    if (reason == 0)
    {
        NSMutableString *member = [self.groupMemberArr objectAtIndex:selectIndex];
        NSArray *infos = [member componentsSeparatedByString:@";&;"];
        NSString*tmp = [infos objectAtIndex:0];
        NSInteger isBan = 1;
        if (infos.count>1)
        {
            NSString *info1 = [infos objectAtIndex:1];
            if ([info1 isEqualToString:@"1"])
            {
                //1代表被禁言了 要解除禁言
                isBan = 0;
            }
        }
        [member setString:[NSString stringWithFormat:@"%@;%d", tmp, isBan]];
        [self.myGridView reloadData];
    }
    else
    {
        [self  popPromptViewWithMsg:@"请求失败，请稍后再试！" AndFrame:CGRectMake(0, 160, 320, 30)];
    }
}

-(void)onModifyGroupCardWithReason:(NSInteger)reason
{
    [self dismissProgressingView];
    if (reason == 0)
    {
        //成功后可以刷新界面
        if (isMyJoinGroup)
        {
            [self.modelEngineVoip queryMemberWithGroupId:self.groupInfo.groupId];
        }
    }
    else
    {
        [self  popPromptViewWithMsg:@"群名片保存失败，请稍后再试！" AndFrame:CGRectMake(0, 160, 320, 30)];
    }
}

-(void)onQueryCardWithReason:(NSInteger)reason andGroupCard:(IMGruopCard *)groupCard
{
    if (reason == 0)
    {
        self.groupCard = groupCard;
        if (!groupCard.belong)
        {
            self.groupCard.belong = self.groupInfo.groupId;
        }
        UITableView* tmpview = (UITableView*) [self.view viewWithTag:TAG_TABLEVIEW_GROUPCARD];
        [tmpview reloadData];
    }
    else
    {
        //失败可以提示
    }
}


#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 23.0f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (tableView.tag == TAG_TABLEVIEW_GROUPCARD)
    {
        UIView *headView = [[[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 23.0f)] autorelease];
        
        UIImageView *image = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"list_bg.png"]];
        [headView addSubview:image];
        [image release];
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(12.0f, 0.0f, 300, 23.0f)];
        [headView addSubview:label];
        label.font = [UIFont systemFontOfSize:13.0f];
        label.backgroundColor = [UIColor clearColor];
        label.text = @"编辑我在该群的名片信息";
        label.textColor = [UIColor whiteColor];
        [label release];        
        return headView;
    }    
    return [[[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 0.0f, 0.0f)] autorelease];;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView.tag == TAG_TABLEVIEW_GROUPCARD)
    {
        if (indexPath.row > 0)
        {
            EditGroupCardViewController *view = [[EditGroupCardViewController alloc] initWithType:indexPath.row andGroupCard:self.groupCard];
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
            [self.navigationController pushViewController:view animated:YES];
            [view release];
        }
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger count = 0;
    if (tableView.tag == TAG_TABLEVIEW_GROUPCARD)
    {
        count = 5;
    }
    return count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString* cellid = @"GroupCell_cellid";
    UITableViewCell *cell = (UITableViewCell*)[tableView dequeueReusableCellWithIdentifier:cellid];
    
    UILabel *captionLabel = nil;
    UILabel *infoLabel = nil;
    if (cell == nil)
    {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellid] autorelease];
        for (UIView *view in cell.subviews)
        {
            [view removeFromSuperview];
        }
            
        UILabel *idLabel = [[UILabel alloc] initWithFrame:CGRectMake(20.0f, 12.0f, 80.0f, 20.0f)];
        idLabel.backgroundColor = VIEW_BACKGROUND_COLOR_WHITE;
        idLabel.font = [UIFont systemFontOfSize:16.0f];
        idLabel.textColor = [UIColor grayColor];
        idLabel.tag = 1001;
        captionLabel = idLabel;
        [cell addSubview:idLabel];
        [idLabel release];
        
        UILabel *tmpLabel = [[UILabel alloc] initWithFrame:CGRectMake(110.0f, 12.0f, 190.0f, 20.0f)];
        tmpLabel.backgroundColor = VIEW_BACKGROUND_COLOR_WHITE;
        tmpLabel.font = [UIFont systemFontOfSize:15.0f];
        tmpLabel.tag = 1002;
        infoLabel = tmpLabel;
        [cell addSubview:tmpLabel];
        [tmpLabel release];        
        infoLabel.textAlignment = NSTextAlignmentLeft;
        UIImageView *lineImg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"voice_mail_line.png"]];
        lineImg.frame = CGRectMake(0.0f, 43.0f, 320.0f, 1.0f);
        [cell addSubview:lineImg];
        [lineImg release];
    }
    else
    {
        captionLabel = (UILabel*)[cell viewWithTag:1001];
        infoLabel    = (UILabel*)[cell viewWithTag:1002];
    }
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    switch (indexPath.row)
    {
        case 0:
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.accessoryType = UITableViewCellAccessoryNone;
            captionLabel.text = @"群组ID";
            if ([self.groupCard.belong length])
            {
                infoLabel.text = self.groupCard.belong;
            }
            else
                infoLabel.text = groupInfo.groupId;
            break;
        case 1:
            captionLabel.text = @"群昵称";
            if (self.groupCard.display)
            {
                infoLabel.text = self.groupCard.display;
            }
            break;
        case 2:
            captionLabel.text = @"电话";
            if (self.groupCard.tel)
            {
                infoLabel.text = self.groupCard.tel;
            }
            break;
        case 3:
            captionLabel.text = @"邮箱";
            if (self.groupCard.mail)
            {
                infoLabel.text = self.groupCard.mail;
            }
            break;
        case 4:
            captionLabel.text = @"备注";
            if (self.groupCard.remark)
            {
                infoLabel.text = self.groupCard.remark;
            }
            break;
        default:
            break;
    }    
    return cell;
}

#pragma mark GradeClassViewController delegate //班级、学生、老师选中名称委托
- (void) selectNamesFinsh:(id)tempData
{
    NSDictionary *studentsDic = tempData;
    
    //有数据才返回
    NSArray *keys = [studentsDic allKeys];
    if (keys) {
        if ([keys count] > 0) {
            [self getAccountInfoWithDic:studentsDic];
        }
    }
    
}

//获取语音通讯的子账号(都是学生)
- (void)getAccountInfoWithDic:(NSDictionary *)dic {
    NSString *loginKey = [ConfigManager sharedConfigManager].loginKey;
    NSMutableArray *postArray = [[NSMutableArray alloc] init];
    
    NSString *tempURL = [ConfigManager getAccountInfo];
    NSDictionary *userInfo = nil;
    
    NSArray *keys = [dic allKeys];
    for (NSString *key in keys) {
        NSDictionary *oneStudentDic = [dic objectForKey:key];
        NSMutableDictionary *postDic = [[NSMutableDictionary alloc] initWithObjectsAndKeys:[oneStudentDic objectForKey:@"xuehao"],@"xuehao",[oneStudentDic objectForKey:@"schoolid"],@"schoolid",[oneStudentDic objectForKey:@"sname"],@"sname", nil];
        NSError *error = nil;
        
        NSData *registerData = [NSJSONSerialization dataWithJSONObject:postDic options:NSJSONWritingPrettyPrinted error:&error];
        
        //json 数据
        NSString *jsonStr = [[NSString alloc] initWithData:registerData encoding:NSUTF8StringEncoding];
        [postArray addObject:jsonStr];
        
        [jsonStr release];
        [postDic release];
    }
    
    userInfo = [NSDictionary dictionaryWithObjectsAndKeys:NotificationGroupInfoViewController,NotificationKey, nil];
    
    NSString *apikey = [[ConfigManager sharedConfigManager].configData objectForKey:@"api_key_value"];
    NSMutableDictionary *headerDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:apikey,@"X-API-KEY",@"application/x-www-form-urlencoded" ,@"Content-Type",nil];
    
    //应用apikey type 老师2，学生 1
    [self formDataRequestWithURL:tempURL UserInfo:userInfo DataArray:postArray Header:headerDic Key:loginKey Type:@"1"];
    [postArray release];
}

#pragma mark -
#pragma mark 语音通讯账号返回 自己服务器的接口
- (void)notificationGroupInfoViewController:(NSNotification*) notification{
    @try
    {
        NSMutableArray *voipIdArray = [[NSMutableArray alloc] init];
        NSArray *array = [notification.userInfo objectForKey:@"account"];
        self.accountsArray = array;
        for (NSDictionary *subaccountInfo in array) {
            [voipIdArray addObject:[subaccountInfo objectForKey:@"voipAccount"]];
        }
        if ([voipIdArray count] > 0) {
            //群组添加子账号
            [self.modelEngineVoip inviteJoinGroupWithGroupId:self.groupInfo.groupId andMembers:voipIdArray andDeclared: nil andConfirm:1];
        }
        [voipIdArray release];
    }
    @catch (NSException *exception) {
        
    }
    @finally {
    }
    
}

//对讲场景状态
- (void)onInterphoneStateWithReason:(NSInteger)reason andConfNo:(NSString*)confNo
{
    [self dismissProgressingView];
    if (reason == 0 && confNo.length > 0)
    {
        IntercomingViewController *intercoming = [[IntercomingViewController alloc] init];
        intercoming.curInterphoneId = confNo;
        intercoming.navigationItem.hidesBackButton = YES;
        intercoming.backView = self.backView;
        [self.navigationController pushViewController:intercoming animated:YES];
        [intercoming release];
    }
    else
    {
        UIAlertView *alertView=nil;
        alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"发起对讲失败，请稍后重试" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [alertView show];
        [alertView release];
    }
}

- (void) onGroupInviteJoinGroupWithReason:(NSInteger)reason
{
    if (reason == 0) {
        if (self.accountsArray) {
            for (NSDictionary *dic in self.accountsArray) {
                //成功后修改名片
                IMGruopCard* groupCard = [[IMGruopCard alloc] init];
                groupCard.belong = self.groupInfo.groupId;
                groupCard.display =  [dic objectForKey:@"sname"];
                NSLog(@"groupCard.display = %@",groupCard.display);
                
                id voipAccount = [dic objectForKey:@"voipAccount"];
                if ([voipAccount isKindOfClass:[NSString class]]) {
                    groupCard.voipAccount =  voipAccount;
                }else if ([voipAccount isKindOfClass:[NSArray class]]) {
                    if ([voipAccount count] > 0) {
                        groupCard.voipAccount =  [voipAccount objectAtIndex:0];
                    }
                    
                }
                NSLog(@"groupCard.voipAccount = %@,leng = %d",groupCard.voipAccount,groupCard.voipAccount.length);
                
                
                [self.modelEngineVoip modifyGroupCard:groupCard];
                [groupCard release];
            }
            
        }
        [self dismissProgressingView];
//        [self popToPreView];
    }
}

@end
