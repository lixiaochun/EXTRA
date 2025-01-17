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

#import "UIselectContactsViewController.h"
#import "UISelectCell.h"
#import "IntercomingViewController.h"
#import "VoipCallController.h"
//#import "VideoViewController.h"
//#import "ViewController.h"
#import "SendIMViewController.h"

#define Confirm 7777
#define notConfirm 8888

@implementation UIselectContactsViewController

@synthesize myTableView;
@synthesize cellDataArray;
@synthesize backView;
@synthesize headerLabel;
@synthesize footerLabel;
@synthesize groupId;

- (id)initWithAccountList:(NSMutableArray*) list andSelectType:(ESelectViewType) type;
{
    self = [super init];
    
    if (self)
    {
        self.cellDataArray = list;
        for (AccountInfo * accounts in self.cellDataArray)
        {
            selectType = type;
            accounts.isChecked = NO;
        }
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
}

#pragma mark - View lifecycle

-(void)btnConfirm
{
    NSMutableString* strVoipID = [[NSMutableString alloc] init];
    int count = 0;
    for (AccountInfo * info in self.cellDataArray)
    {
        if (info.isChecked)
        {
            if (count == 0)
            {
                [strVoipID appendString:info.voipId];
            }
            else
            {
                [strVoipID appendString:@","];
                [strVoipID appendString:info.voipId];
            }
            count++;
        }
    }
    if (count <= 0)
    {
        [strVoipID release];
        return;
    }
    if(selectType == ESelectViewType_InterphoneView)
    {
        NSString *appid = self.modelEngineVoip.appID;
        
        NSMutableArray *selectArray = [[NSMutableArray alloc] init];
        for (AccountInfo * info in self.cellDataArray)
        {
            if (info.isChecked)
            {
                [selectArray addObject:info.voipId];
            }
        }
        
        if (appid.length>0)
        {
            [self displayProgressingView];
            [self.modelEngineVoip startInterphoneWithJoiner:selectArray inAppId:appid];
        }
        [selectArray release];
    }
    else if(selectType == ESelectViewType_VoipView)
    {
        //免费电话
    }
    else if(selectType == ESelectViewType_Video)
    {
        //视频通话
        NSString *callVoip = nil;
        for (AccountInfo * info in self.cellDataArray)
        {
            if (info.isChecked)
            {
                callVoip = info.voipId;
                break;
            }
        }
        if (callVoip.length > 0)
        {
//            VideoViewController *videoView = [[VideoViewController alloc] initWithCallerName:callVoip andVoipNo:callVoip andCallstatus:0];
//            [self popToPreView];
//            [self.backView presentModalViewController:videoView animated:YES];
//            [videoView release];
        }
    }
    else if(selectType == ESelectViewType_IMMsgView)
    {
        //点对点im
        NSString *callVoip = nil;
        for (AccountInfo * info in self.cellDataArray)
        {
            if (info.isChecked)
            {
                callVoip = info.voipId;
                break;
            }
        }
        if (callVoip.length > 0)
        {
            SendIMViewController *imdetailView = [[SendIMViewController alloc] initWithReceiver:callVoip];
            imdetailView.backView = self.backView;
            [self.navigationController pushViewController:imdetailView animated:YES];
            [imdetailView release];
        }
    }
    else if(ESelectViewType_GroupMemberView == selectType)
    {
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"\n" message:@"\n \n" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定",nil];
        alert.tag = 9999;
        [self willPresentAlertView:alert ];
        UILabel *lbl=[[UILabel alloc]initWithFrame:CGRectMake(30,-70,290,40)];
        [lbl setText:@"                 邀请信息"];
        lbl.numberOfLines = 0;
        [lbl setBackgroundColor:[UIColor clearColor]];
        [lbl setTextColor:[UIColor whiteColor]];
        [alert addSubview:lbl];
        [lbl release];
        
        UILabel *ulbl=[[UILabel alloc]initWithFrame:CGRectMake(5,-30,270,40)];
        [ulbl setText:@"        请输入邀请对方加入群组的理由，并且选择是否需要被邀请人确认（即自动加入）"];
        ulbl.numberOfLines = 0;
        ulbl.lineBreakMode = UILineBreakModeCharacterWrap;
        ulbl.font = [UIFont systemFontOfSize:14];
        [ulbl setBackgroundColor:[UIColor clearColor]];
        [ulbl setTextColor:[UIColor whiteColor]];
        [alert addSubview:ulbl];
        [ulbl release];
                      
        myTextField = [[[UITextField alloc] initWithFrame:CGRectMake(20.0, 20, 240.0, 20.0)] autorelease];
        myTextField.tag = 9999;
        myTextField.placeholder = @"请输入邀请理由";
        [myTextField setBackgroundColor:[UIColor whiteColor]];
        myTextField.delegate = self;
        [alert addSubview:myTextField];
        
        UIButton* btn = [UIButton buttonWithType:(UIButtonTypeCustom)];
        btn.frame = CGRectMake(0, 45, 220, 25);
        UIImage* img = [UIImage imageNamed:@"choose_ invite_off.png"];
        isConfirm = 1;
        btn.tag = Confirm;
        [btn setImage: img forState:(UIControlStateNormal)];
        btn.titleLabel.font = [UIFont systemFontOfSize:14];
        [btn setTitle:@"  需要被邀请人确认     " forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(btnChoose:) forControlEvents:(UIControlEventTouchUpInside)];
        [alert addSubview:btn];

        [alert show];
        [alert release];
        [myTextField becomeFirstResponder];
    }
    [strVoipID release];
}
-(void)btnChoose:(id)sender
{
    UIButton* btn = sender;
    if (btn.tag == Confirm)
    {
        btn.tag = notConfirm;
        UIImage* img = [UIImage imageNamed:@"choose_ invite_on.png"];
        [btn setImage: img forState:(UIControlStateNormal)];
        isConfirm = 0;
    }
    else
    {
        btn.tag = Confirm;
        UIImage* img = [UIImage imageNamed:@"choose_ invite_off.png"];
        [btn setImage: img forState:(UIControlStateNormal)];
        isConfirm = 1;
    }
}
- (void)willPresentAlertView:(UIAlertView *)openURLAlert
{
    if (openURLAlert.tag == 9999) {
        [openURLAlert setBounds:CGRectMake(-10, -80, 300, 270 )];
    }
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    @try
    {
        if (alertView.tag == 9999)
        {
             if (buttonIndex == 1)
             {
                 NSMutableArray *selectArray = [[NSMutableArray alloc] init];
                 for (AccountInfo * info in self.cellDataArray)
                 {
                     if (info.isChecked)
                     {
                         [selectArray addObject:info.voipId];
                     }
                 }
                 [self displayProgressingView];
                 [self.modelEngineVoip inviteJoinGroupWithGroupId:self.groupId
                                                       andMembers:selectArray
                                                      andDeclared: myTextField.text
                                                       andConfirm:isConfirm];
                 [selectArray release];
             }
        }
        else
        {
            if (buttonIndex == 1)
            {
                if ([utextfield.text length]==0) {
                    UIAlertView* alert;
                    alert = [[UIAlertView alloc]initWithTitle:@"提示" message:@"邀请的号码不能为空" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
                    [alert show];
                    [alert release];
                    return;
                }
                else
                {
                    AccountInfo *content = [[AccountInfo alloc] init];
                    content.voipId = utextfield.text;
                    [cellDataArray addObject:content];
                    [content release];
                    [self.myTableView reloadData];
                }
            }
        }
    }
    @catch (NSException *exception) {
        
    }
    @finally {
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
    else
    {
        if (range.length == 1) {
            return YES;
        }
        NSMutableString *text = [[utextfield.text mutableCopy] autorelease];
        [text replaceCharactersInRange:range withString:string];
        return [text length] <= 15;
    }
}
#pragma mark - View 
- (void)viewDidLoad
{
    [super viewDidLoad];
    selectedIndex = -1;
    lastSelectedIndex = -1;
    
    UIBarButtonItem *btnBack = [[UIBarButtonItem alloc] initWithCustomView:[CommonTools navigationItemBtnInitWithTitle:@"返回" target:self action:@selector(goBack)]];
    self.navigationItem.leftBarButtonItem = btnBack;
    [btnBack release];    
    self.title = @"选择联系人";
    if (selectType == ESelectViewType_VoipView)
    {
        UIBarButtonItem *btnCancel=[[UIBarButtonItem alloc] initWithCustomView:[CommonTools navigationItemBtnInitWithTitle:@"取消" target:self action:@selector(popToPreView)]];
        self.navigationItem.rightBarButtonItem = btnCancel;
        [btnCancel release];
    }
    else
    {
        UIBarButtonItem *btnGetContacts=[[UIBarButtonItem alloc] initWithCustomView:[CommonTools navigationItemBtnInitWithTitle:@"确定" target:self action:@selector(btnConfirm)]];
        self.navigationItem.rightBarButtonItem = btnGetContacts;
        [btnGetContacts release];
    }
    
    self.view.backgroundColor = VIEW_BACKGROUND_COLOR_WHITE;
    
    UIView* headerView = [[UIView alloc] init];
    headerView.frame = CGRectMake(0, 0, 320, 29);
    UIImageView *imgHeader = [[UIImageView alloc] initWithFrame:headerView.frame];
    imgHeader.image = [UIImage imageNamed:@"point_bg.png"];
    [headerView addSubview:imgHeader];
    [imgHeader release];
    UILabel *lbHeader = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 29.0f)] ;
    lbHeader.backgroundColor = [UIColor clearColor];
    lbHeader.font = [UIFont systemFontOfSize:13.0f];
    lbHeader.textColor = [UIColor whiteColor];
    lbHeader.textAlignment = UITextAlignmentCenter;
    [headerView addSubview:lbHeader];
    self.headerLabel = lbHeader;
    [lbHeader release];
    [self.view addSubview:headerView];
    [headerView release];
    
    CGFloat footerHeight = 0;
    if (selectType == ESelectViewType_InterphoneView)
    {
        footerHeight = 44.0f;
    }
    
	UITableView *tableView = nil;
    if (IPHONE5)
    {
        tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 29, 320, 548-29-footerHeight-44)
                                                 style:UITableViewStylePlain];
    }
    else
    {
        tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 29, 320, 460-29-footerHeight-44)
                                                 style:UITableViewStylePlain];
    }
    tableView.autoresizingMask = (UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight);
	tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
	tableView.delegate = self;
	tableView.dataSource = self;
    tableView.backgroundColor = [UIColor clearColor];
    self.myTableView = tableView;
	[self.view addSubview:tableView];
	[tableView release];
    
    //if (selectType == ESelectViewType_InterphoneView  || selectType == ESelectViewType_VoiceMsgView)
    {
        UIView* footerView = [[UIView alloc] init];
        footerView.frame = CGRectMake(0, 460-44.0f-44.0f, 320, 44);
        if (IPHONE5)
        {
            footerView.frame = CGRectMake(0, 548-44.0f-44.0f, 320, 44);
        }
        UIImageView *imgfooter = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 44.0f)];
        imgfooter.image = [UIImage imageNamed:@"top_bg.png"];
        [footerView addSubview:imgfooter];
        [imgfooter release];
        UILabel *lbFooter = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 250.0f, 44.0f)] ;
        lbFooter.backgroundColor = [UIColor clearColor];
        lbFooter.textColor = [UIColor whiteColor];
        lbFooter.textAlignment = UITextAlignmentCenter;
        lbFooter.font = [UIFont systemFontOfSize:16.0f];
        [footerView addSubview:lbFooter];
        self.footerLabel = lbFooter;
        [lbFooter release];
        self.footerLabel.text = @"还未勾选联系人，请勾选。";
        UIButton *btnAdd = [UIButton buttonWithType:UIButtonTypeCustom];
        [btnAdd setBackgroundImage:[UIImage imageNamed:@"button02_on.png"] forState:UIControlStateNormal];
        [btnAdd setBackgroundImage:[UIImage imageNamed:@"button02_off.png"] forState:UIControlStateHighlighted];
        [btnAdd setTitle:@"添加" forState:UIControlStateNormal];
        [btnAdd setTitle:@"添加" forState:UIControlStateHighlighted];
        btnAdd.frame = CGRectMake(226, 3.5f, 91, 37);
        [btnAdd addTarget:self action:@selector(addMember) forControlEvents:(UIControlEventTouchUpInside)];
        [footerView addSubview:btnAdd];
        [self.view addSubview:footerView];
        [footerView release];
    }
}
-(void)addMember
{
    UIAlertView *alertview = [[UIAlertView alloc] initWithTitle:@"添加号码" message:@"   \0 \n \n" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    utextfield = [[UITextField alloc] initWithFrame:CGRectMake(22.0, 60.0, 240.0, 25.0)];
    utextfield.placeholder = @"请输入号码";
    [utextfield setBackgroundColor:[UIColor whiteColor]];
    utextfield.delegate = self;
    utextfield.keyboardType =UIKeyboardTypePhonePad;
    utextfield.borderStyle = UITextBorderStyleRoundedRect;
    [alertview addSubview:utextfield];
    [alertview show];
    [alertview release];
    [utextfield becomeFirstResponder];
    [utextfield release];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.modelEngineVoip.UIDelegate = self;
    NSString* str = @"";
    if (selectType == ESelectViewType_InterphoneView)
    {
        str = @"（可多选）";
    }    
    self.headerLabel.text = [NSString  stringWithFormat:@"请选择联系人%@",str];
}

- (void)viewDidUnload
{
    [self setMyTableView:nil];
    [self setCellDataArray:nil];
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (void)dealloc
{
    self.headerLabel = nil;
    self.footerLabel = nil;
    self.myTableView = nil;
    self.cellDataArray = nil;
    self.groupId = nil;
    [super dealloc];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return cellDataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UISelectCell *cell = nil;
    
    static NSString *cellIdentifier = @"Cell";
    
    cell = (UISelectCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if ( cell == nil )
    {
        cell = [[[UISelectCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier] autorelease];
    }
    if (selectType == ESelectViewType_VoipView || selectType == ESelectViewType_Video)
    {
        cell.isSingleCheck = YES;
    }
   AccountInfo *content = [cellDataArray objectAtIndex:indexPath.row];
    [cell makeCellWithVoipInfo:content];
	return cell;
}

-(void)goBack
{
    if (selectType == ESelectViewType_GroupMemberView)
    {
        [self.navigationController popToViewController:self.backView animated:YES];
    }
    else
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
}
#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (selectType == ESelectViewType_VoipView)
    {
        //免费电话
        AccountInfo* info = [cellDataArray objectAtIndex:indexPath.row];
        if (info.voipId.length > 0)
        {
//            if (backView && [backView isKindOfClass:[ViewController class]])
//            {
//                ((ViewController*)backView).tf_Account.text = info.voipId;
//                ((ViewController*)backView).voipAccount = info.voipId;
//                UISelectCell* cell = (UISelectCell *)[tableView cellForRowAtIndexPath:indexPath];
//                [cell resetCheckImge:YES];
//                [self performSelector:@selector(goBack) withObject:self afterDelay:0.2];
//            }
        }
    }
    else if (selectType == ESelectViewType_Video || selectType == ESelectViewType_IMMsgView)
    {
        lastSelectedIndex = selectedIndex;
        if ( lastSelectedIndex != -1 )
        {
            AccountInfo* info = [cellDataArray objectAtIndex:lastSelectedIndex];
            info.isChecked = !info.isChecked;
            
            NSIndexPath *lastIndexPath = [NSIndexPath indexPathForRow:lastSelectedIndex inSection:0];
            UISelectCell *lastCell = (UISelectCell *)[tableView cellForRowAtIndexPath:lastIndexPath];
            [lastCell resetCheckImge:info.isChecked];
        }
        
        selectedIndex = indexPath.row;
        if ( selectedIndex != lastSelectedIndex )
        {
            AccountInfo* info = [cellDataArray objectAtIndex:indexPath.row];
            info.isChecked = !info.isChecked;
            
            UISelectCell* cell = (UISelectCell *)[tableView cellForRowAtIndexPath:indexPath];
            [cell resetCheckImge:info.isChecked];
        }
        else    //在当前选中的cell中反选，置为初值
        {
            lastSelectedIndex = -1;
            selectedIndex = -1;
        }
    }
    else
    {
        AccountInfo* info = [cellDataArray objectAtIndex:indexPath.row];
        if (selectCount >= 7 &&  selectType == ESelectViewType_InterphoneView && !info.isChecked)
        {
            [self  popPromptViewWithMsg:@"实时对讲最多只能选择7个联系人！" AndFrame:CGRectMake(0, 160, 320, 30)];
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
            return;
        }
        info.isChecked = !info.isChecked;
        if (info.isChecked)
        {
            selectCount ++;
        }
        else
            selectCount --;
        
        if (selectCount <= 0)
        {
            self.footerLabel.text = @"还未勾选联系人，请勾选。";
        }
        else
        {
            self.footerLabel.text = [NSString stringWithFormat:@"已勾选%d个联系人。",selectCount];
        }
        
        UISelectCell* cell = (UISelectCell *)[tableView cellForRowAtIndexPath:indexPath];
        [cell resetCheckImge:info.isChecked];
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
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
        [self dismissProgressingView];
        [self goBack];
    }
}
@end

