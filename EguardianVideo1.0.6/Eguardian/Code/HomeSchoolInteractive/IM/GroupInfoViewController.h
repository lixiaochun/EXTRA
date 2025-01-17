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

#import "UIBaseViewController.h"
#import "MMGridView.h"
#import "EditGroupCardViewController.h"

//群成员
@interface GroupInfoViewController : UIBaseViewController<MMGridViewDelegate, MMGridViewDataSource, UIAlertViewDelegate,UITextFieldDelegate, UIActionSheetDelegate,UITableViewDataSource, UITableViewDelegate>
{
    UITextField* declaredTextField;
    UIButton *rightBtn;
    int      selectIndex;
    UIView*  selfview;
    UITableView *groupCardTableView;
}
@property (nonatomic, retain) IMGroup *groupInfo;
@property (nonatomic, retain) IMGruopCard *groupCard;
@property (nonatomic, retain) UIViewController *backView;
@property (nonatomic, retain) UIImageView *titleImgView;

//记录添回群成员的数据
@property (nonatomic, retain) NSArray *accountsArray;
- (id)initWithGroupId:(NSString*)groupid andIsMyJoin:(BOOL)isJoin andPermission:(NSInteger)permission;
@end
