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

#import "ChatSendHelper.h"
#import "ConvertToCommonEmoticonsHelper.h"
#import "GoodsEntity.h"
#import "OrderEntity.h"
#import "EMGoodsMessageBody.h"

@interface ChatImageOptions : NSObject<IChatImageOptions>

@property (assign, nonatomic) CGFloat compressionQuality;

@end

@implementation ChatImageOptions

@end

@implementation ChatSendHelper

+(EMMessage *)sendTextMessageWithString:(NSString *)str
                             toUsername:(NSString *)username
                            isChatGroup:(BOOL)isChatGroup
                      requireEncryption:(BOOL)requireEncryption
{
    // 表情映射。
    NSString *willSendText = [ConvertToCommonEmoticonsHelper convertToCommonEmoticons:str];
    EMChatText *text = [[EMChatText alloc] initWithText:willSendText];
    EMTextMessageBody *body = [[EMTextMessageBody alloc] initWithChatObject:text];
    return [self sendMessage:username messageBody:body isChatGroup:isChatGroup requireEncryption:requireEncryption];
}

+(EMMessage *)sendImageMessageWithImage:(UIImage *)image
                             toUsername:(NSString *)username
                            isChatGroup:(BOOL)isChatGroup
                      requireEncryption:(BOOL)requireEncryption
{
    EMChatImage *chatImage = [[EMChatImage alloc] initWithUIImage:image displayName:@"image.jpg"];
    id <IChatImageOptions> options = [[ChatImageOptions alloc] init];
    [options setCompressionQuality:0.6];
    [chatImage setImageOptions:options];
    EMImageMessageBody *body = [[EMImageMessageBody alloc] initWithImage:chatImage thumbnailImage:nil];
    return [self sendMessage:username messageBody:body isChatGroup:isChatGroup requireEncryption:requireEncryption];
}

+(EMMessage *)sendVoice:(EMChatVoice *)voice
             toUsername:(NSString *)username
            isChatGroup:(BOOL)isChatGroup
      requireEncryption:(BOOL)requireEncryption
{
    EMVoiceMessageBody *body = [[EMVoiceMessageBody alloc] initWithChatObject:voice];
    return [self sendMessage:username messageBody:body isChatGroup:isChatGroup requireEncryption:requireEncryption];
}

+(EMMessage *)sendVideo:(EMChatVideo *)video
             toUsername:(NSString *)username
            isChatGroup:(BOOL)isChatGroup
      requireEncryption:(BOOL)requireEncryption
{
    EMVideoMessageBody *body = [[EMVideoMessageBody alloc] initWithChatObject:video];
    return [self sendMessage:username messageBody:body isChatGroup:isChatGroup requireEncryption:requireEncryption];
}

+(EMMessage *)sendLocationLatitude:(double)latitude
                         longitude:(double)longitude
                           address:(NSString *)address
                        toUsername:(NSString *)username
                       isChatGroup:(BOOL)isChatGroup
                 requireEncryption:(BOOL)requireEncryption
{
    EMChatLocation *chatLocation = [[EMChatLocation alloc] initWithLatitude:latitude longitude:longitude address:address];
    EMLocationMessageBody *body = [[EMLocationMessageBody alloc] initWithChatObject:chatLocation];
    return [self sendMessage:username messageBody:body isChatGroup:isChatGroup requireEncryption:requireEncryption];
}

// 发送消息
+(EMMessage *)sendMessage:(NSString *)username
              messageBody:(id<IEMMessageBody>)body
              isChatGroup:(BOOL)isChatGroup
        requireEncryption:(BOOL)requireEncryption
{
    EMMessage *retureMsg = [[EMMessage alloc] initWithReceiver:username bodies:[NSArray arrayWithObject:body]];
    retureMsg.requireEncryption = requireEncryption;
    retureMsg.isGroup = isChatGroup;
    
    EMMessage *message = [[EaseMob sharedInstance].chatManager asyncSendMessage:retureMsg progress:nil];
    
    return message;
}

#pragma mark 发送商品消息
+(EMMessage *)sendMessageWithGoods:(GoodsEntity *)goods toUsername:(NSString *)username
{
    if (!goods) {
        return nil;
    }
    EMChatText *txtChat = [[EMChatText alloc] initWithText:@"扩展消息"];
    EMGoodsMessageBody *body = [[EMGoodsMessageBody alloc] initWithChatObject:txtChat];
    
    // 处理 description  40个字
    if ([goods.goodsDescription length] > 40) {
        goods.goodsDescription = [goods.goodsDescription substringToIndex:40];
    }
    
    // 生成message
    EMMessage *message = [[EMMessage alloc] initWithReceiver:username bodies:@[body]];
    message.isGroup = NO; // 设置是否是群聊
    
    NSDictionary *ext = @{@"extGoodsId": [NSString stringWithFormat:@"%lld", goods.goodsId],
                          @"extgoodsDescription": [NSString stringWithFormat:@"%@", goods.goodsDescription],
                          @"extPrice": [NSString stringWithFormat:@"%0.2f", [goods.price floatValue]],
                          @"extFirstImageUrl": [NSString stringWithFormat:@"%@", goods.firstImageUrl],
                          @"extImageCount": [NSString stringWithFormat:@"%d", goods.goodsImagesCount],
                          @"extMessageType": @"extMessageType_Goods"
                          };
    message.ext = ext; // 添加扩展，key和value必须是基本类型，且不能是json
    
    // 发送消息
    EMMessage *messagex = [[EaseMob sharedInstance].chatManager asyncSendMessage:message progress:nil];
    
    return messagex;
    
    
    //
}

#pragma mark 发送商品消息
+(EMMessage *)sendMessageWithOrder:(OrderEntity *)order toUsername:(NSString *)username
{
    if (!order) {
        return nil;
    }
    EMChatText *txtChat = [[EMChatText alloc] initWithText:@"扩展消息"];
    EMGoodsMessageBody *body = [[EMGoodsMessageBody alloc] initWithChatObject:txtChat];
    
    // 处理 description  40个字
    if ([order.orderDescription length] > 40) {
        order.orderDescription = [order.orderDescription substringToIndex:40];
    }
    
    // 生成message
    EMMessage *message = [[EMMessage alloc] initWithReceiver:username bodies:@[body]];
    message.isGroup = NO; // 设置是否是群聊
    
    NSDictionary *ext = @{@"extOrderId": [NSString stringWithFormat:@"%@", order.orderNo],
                          @"extgoodsDescription": [NSString stringWithFormat:@"%@", order.orderDescription],
                          @"extPrice": [NSString stringWithFormat:@"%0.2f", [order.price floatValue]],
                          @"extFirstImageUrl": [NSString stringWithFormat:@"%@", order.firstImageUrl],
                          @"goodsImagesCount": [NSString stringWithFormat:@"%d", 0],
                          @"extMessageType": @"extMessageType_Order"
                          };
    message.ext = ext; // 添加扩展，key和value必须是基本类型，且不能是json
    
    // 发送消息
    EMMessage *messagex = [[EaseMob sharedInstance].chatManager asyncSendMessage:message progress:nil];
    
    return messagex;
}

@end
