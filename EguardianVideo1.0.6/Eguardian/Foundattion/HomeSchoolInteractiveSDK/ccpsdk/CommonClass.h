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
#ifndef CPPCallManagerSDK_CCPCommon_h
#define CPPCallManagerSDK_CCPCommon_h
#define ERROR_FILE              29010//文件过大



#import <Foundation/Foundation.h>

//回调函数Reason枚举定义
//状态，取值有0（成功），1（无返回），2（上传失败），3（查询新的语音留言失败），4（下载失败），5（已获取成员列表失败）6（上传语音过短）7(连接文件服务器失败)
typedef enum  {
    ESucceed=0,
    ENOResponse,
    EUploadFailed,
    ERNewVoiceFailed,
    EDwonLoadIMChunkedFailed,
    EGetMemberListFailed,
    EUploadFailedTimeIsShort,
    EUploadConnectFailed,
    EUploadCancel
}EVoiceMsgReason;


//服务器录音文件状态枚举定义
//状态，取值有0（队列），1（发送中），2（已通知），3（接收端不在线，通知失败），4（已接收），5（已下载）
typedef enum {
    EQueue,
    ESending,
    ENotification,
    EOffLine,
    EReceived,
    EDownloaded,
}EVoiceFileState;


typedef enum {
	Rotate_Auto,
	Rotate_0,
	Rotate_90,
	Rotate_180,
	Rotate_270
} Rotate;


typedef enum
{
    eAUDIO_AGC,   //自动增益控制，默认底层是关闭，开启后默认模式是kAgcAdaptiveAnalog
    eAUDIO_EC,	 //回音消除，默认开启，模式默认是kEcAecm
    eAUDIO_NS	 //静音抑制，默认开启，模式默认是kNsVeryHighSuppression
}EAudioType;

typedef enum    // type of Noise Suppression
{
    eNsUnchanged = 0,   // previously set mode
    eNsDefault,         // platform default
    eNsConference,      // conferencing default
    eNsLowSuppression,  // lowest suppression
    eNsModerateSuppression,
    eNsHighSuppression,
    eNsVeryHighSuppression,     // highest suppression
}EAudioNsMode;

typedef enum                  // type of Automatic Gain Control
{
    eAgcUnchanged = 0,
    // platform default
    eAgcDefault,
    // adaptive mode for use when analog volume control exists (e.g. for
    // PC softphone)
    eAgcAdaptiveAnalog,
    // scaling takes place in the digital domain (e.g. for conference servers
    // and embedded devices)
    eAgcAdaptiveDigital,
    // can be used on embedded devices where the capture signal level
    // is predictable
    eAgcFixedDigital
}EAudioAgcMode;


// EC modes
typedef enum                   // type of Echo Control
{
    eEcUnchanged = 0,          // previously set mode
    eEcDefault,                // platform default
    eEcConference,             // conferencing default (aggressive AEC)
    eEcAec,                    // Acoustic Echo Cancellation
    eEcAecm,                   // AEC mobile
}EAudioEcMode;

typedef enum
{
    SYSCallComing =0,
    BatteryLower
}CCPEvents;

@interface StatisticsInfo:NSObject
@property (nonatomic,assign)   NSUInteger  rlFractionLost;    //上次调用获取统计后这一段时间的丢包率，范围是0~255，255是100%丢失。
@property (nonatomic,assign)   NSUInteger  rlCumulativeLost;    //开始通话后的所有的丢包总个数
@property (nonatomic,assign)   NSUInteger  rlExtendedMax;       //开始通话后应该收到的包总个数
@property (nonatomic,assign)   NSUInteger  rlJitterSamples;     //rtp抖动率
@property (nonatomic,assign)   NSInteger   rlRttMs;                      //延迟时间，单位是ms
@property (nonatomic,assign)   NSUInteger  rlBytesSent;         //开始通话后发送的总字节数
@property (nonatomic,assign)   NSUInteger  rlPacketsSent;       //开始通话后发送的总RTP包个数
@property (nonatomic,assign)   NSUInteger  rlBytesReceived;     //开始通话后收到的总字节数
@property (nonatomic,assign)   NSUInteger  rlPacketsReceived;   //开始通话后收到的总RTP包个数
@end
//摄像头的信息类
@interface CameraCapabilityInfo : NSObject
@property (nonatomic,assign) NSInteger width;
@property (nonatomic,assign) NSInteger height;
@property (nonatomic,assign) NSInteger maxfps;
@end

//摄像头设备信息类
@interface CameraDeviceInfo : NSObject
@property (nonatomic,assign) NSInteger index;
@property (nonatomic,retain) NSString *name;
@property (nonatomic,retain) NSArray *capabilityArray;
@end

//下载结构文件参数结构定义
@interface DownloadInfo:NSObject
@property (nonatomic,retain) NSString*  fileUrl;//网络文件地址
@property (nonatomic,retain) NSString*  fileName;//本地存储地址
@property (nonatomic,assign) BOOL       isChunked;//是否chunked方式上传
@end

#pragma mark - 实时语音消息的类
//实时对讲机消息基类定义
@interface InterphoneMsg : NSObject
@property (nonatomic, retain) NSString *interphoneId;
@end

//实时对讲解散消息类定义
@interface InterphoneOverMsg : InterphoneMsg
@end

//邀请加入实时对讲消息类定义
@interface InterphoneInviteMsg : InterphoneMsg
@property (nonatomic, retain) NSString *dateCreated;
@property (nonatomic, retain) NSString *fromVoip;
@end

//有人加入实时对讲消息类定义
@interface InterphoneJoinMsg : InterphoneMsg
@property (nonatomic, retain) NSArray *joinArr;
@end


//有人退出实时对讲消息类定义
@interface InterphoneExitMsg : InterphoneMsg
@property (nonatomic, retain) NSArray *exitArr;

@end

//实时对讲控麦消息类定义
@interface InterphoneControlMicMsg : InterphoneMsg
@property (nonatomic, retain) NSString *voip;
@end

//实时对讲放麦消息类定义
@interface InterphoneReleaseMicMsg : InterphoneMsg
@property (nonatomic, retain) NSString *voip;
@end

//获取到的对讲成员信息
@interface InterphoneMember : NSObject
@property (nonatomic, retain) NSString *type;
@property (nonatomic, retain) NSString *online;
@property (nonatomic, retain) NSString *voipId;
@property (nonatomic, retain) NSString *mic;
@end

#pragma mark - 聊天室相关类
//聊天室消息基类定义
@interface ChatroomMsg: NSObject
@property (nonatomic, retain) NSString *roomNo;
@end

//有人加入聊天室消息类定义
@interface ChatroomJoinMsg : ChatroomMsg
@property (nonatomic, retain) NSArray *joinArr;
@end

//有人退出聊天室消息类定义
@interface ChatroomExitMsg : ChatroomMsg
@property (nonatomic, retain) NSArray *exitArr;
@end

@interface ChatroomRemoveMemberMsg : ChatroomMsg
@property (nonatomic, retain) NSString *who;
@end;

@interface ChatroomDismissMsg : ChatroomMsg
@end;

//获取到的对讲成员信息
@interface ChatroomMember : NSObject
@property (nonatomic, retain) NSString *type;
@property (nonatomic, retain) NSString *number;
@end

//聊天室信息类
@interface Chatroom : NSObject
@property (nonatomic, retain) NSString *roomNo;
@property (nonatomic, retain) NSString *roomName;
@property (nonatomic, retain) NSString *creator;
@property (nonatomic, assign) NSInteger square;
@property (nonatomic, retain) NSString *keywords;
@property (nonatomic, assign) NSInteger joinNum;
@property (nonatomic, assign) NSInteger validate;
@end


#pragma mark - 实时消息相关类

//基类
@interface InstanceMsg : NSObject
@end

//文本消息
@interface IMTextMsg : InstanceMsg
@property (nonatomic, retain) NSString *msgId;
@property (nonatomic, retain) NSString *dateCreated;
@property (nonatomic, retain) NSString *sender;
@property (nonatomic, retain) NSString *receiver;
@property (nonatomic, retain) NSString *message;
@property (nonatomic, retain) NSString *userData;
@property (nonatomic, retain) NSString *status;
@end

//附件消息
@interface IMAttachedMsg : InstanceMsg
@property (nonatomic, retain) NSString *userData;
@property (nonatomic, retain) NSString *msgId;
@property (nonatomic, retain) NSString *dateCreated;
@property (nonatomic, retain) NSString *sender;
@property (nonatomic, retain) NSString *receiver;
@property (nonatomic, assign) NSInteger fileSize;
@property (nonatomic, retain) NSString *fileUrl;
@property (nonatomic, retain) NSString *ext;
@property (nonatomic, assign) BOOL     chunked;
@end


//解散群组
@interface IMDismissGroupMsg : InstanceMsg
@property (nonatomic, retain) NSString *groupId;
@end


//收到邀请
@interface IMInviterMsg : InstanceMsg
@property (nonatomic, retain) NSString *groupId;
@property (nonatomic, retain) NSString *admin;
@property (nonatomic, retain) NSString *declared;
@property (nonatomic, retain) NSString *confirm;
@end

//收到申请
@interface IMProposerMsg : InstanceMsg
@property (nonatomic, retain) NSString *groupId;
@property (nonatomic, retain) NSString *proposer;
@property (nonatomic, retain) NSString *declared;
@property (nonatomic, retain) NSString *dateCreated;
@end

//有成员加入
@interface IMJoinGroupMsg : IMProposerMsg
@end

//退出群组
@interface IMQuitGroupMsg : InstanceMsg
@property (nonatomic, retain) NSString *groupId;
@property (nonatomic, retain) NSString *member;
@end


//移除成员
@interface IMRemoveMemberMsg : InstanceMsg
@property (nonatomic, retain) NSString *groupId;
@end

//答复申请加入
@interface IMReplyJoinGroupMsg : InstanceMsg
@property (nonatomic, retain) NSString *groupId;
@property (nonatomic, retain) NSString *admin;
@property (nonatomic, retain) NSString *confirm;
@end

//合作方消息
@interface IMCooperMsg : IMAttachedMsg
@property (nonatomic, retain) NSString * message;
@property (nonatomic, assign) NSInteger type;
@end
#endif

