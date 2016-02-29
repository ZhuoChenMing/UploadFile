//
//  UploadFile.h
//  UploadFile
//
//  Created by 酌晨茗 on 16/2/26.
//  Copyright © 2016年 酌晨茗. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol uploadFileDelegate <NSObject>

- (void)finisheWithData:(NSData *)data;

@end

@interface UploadFile : NSObject

/*
 urlstring  接口
 parameter  参数名
 fileData   上传的文件
 fileName   文件名（最好带上后缀名）
 dic        其他参数
 
 支持 avi bmp jpeg jpg png mp3 mp4 txt doc aac ppt pdf等格式
 不够用自行在上传类型中添加
*/

@property (nonatomic, assign) id<uploadFileDelegate>delegate;

- (void)uploadFileWithURLString:(NSString *)urlstring
                      parameter:(NSString *)parameter
                       fileData:(NSData *)filedata
                       fileName:(NSString *)fileName
                            dic:(NSDictionary *)dic;

@end
