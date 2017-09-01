/************************************************************
  *  * EaseMob CONFIDENTIAL 
  * __________________ 
  * Copyright (C) 2013-2014 EaseMob Technologies. All rights reserved. 
  *  
  * NOTICE: All information contained herein is, and remains 
  * the property of EaseMob Technologies.
  * Dissemination of this information or reproduction of this material 
  * is strictly forbidden unless prior written permission is obtained
  * from EaseMob Technologies.
  */

#import <Foundation/Foundation.h>

#import "OrderEntity.h"


#define KFIRETIME 20

@interface MessageModel : NSObject
{
    BOOL _isPlaying;
}

@property (nonatomic) MessageBodyType type;
@property (nonatomic) MessageDeliveryState status;

@property (nonatomic) BOOL isSender;    //是否是发送者
@property (nonatomic) BOOL isRead;      //是否已读
@property (nonatomic) BOOL isChatGroup;  //是否是群聊

@property (nonatomic, strong) NSString *messageId;
@property (nonatomic, strong) NSURL *headImageURL;
@property (nonatomic, strong) NSString *nickName;
@property (nonatomic, strong) NSString *username;

@property (nonatomic, assign) long long userId;

//text
@property (nonatomic, strong) NSString *content;

//image
@property (nonatomic) CGSize size;
@property (nonatomic) CGSize thumbnailSize;
@property (nonatomic, strong) NSURL *imageRemoteURL;
@property (nonatomic, strong) NSURL *thumbnailRemoteURL;
@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong) UIImage *thumbnailImage;

//audio
@property (nonatomic, strong) NSString *localPath;
@property (nonatomic, strong) NSString *remotePath;
@property (nonatomic) NSInteger time;
@property (nonatomic, strong) EMChatVoice *chatVoice;
@property (nonatomic) BOOL isPlaying;
@property (nonatomic) BOOL isPlayed;

//location
@property (nonatomic, strong) NSString *address;
@property (nonatomic) double latitude;
@property (nonatomic) double longitude;

// goods
@property (nonatomic, strong) NSString *goodsId;
@property (nonatomic, strong) NSString *goodsDescription;
@property (nonatomic, strong) NSString *goodsFirstImageURL;
@property (nonatomic, strong) NSString *goodsPrice;
@property (nonatomic, strong) NSString *OrderId;

// ext
@property (nonatomic, assign) extMessageType extMessageType;


// order
@property (nonatomic, strong) OrderEntity *order;

@property (nonatomic, strong)id<IEMMessageBody> messageBody;
@property (nonatomic, strong)EMMessage *message;


//- (void) setExtMessageTypeWithString:(NSString *)type;

@end
