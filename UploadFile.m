//
//  UploadFile.m
//  UploadFile
//
//  Created by 酌晨茗 on 16/2/26.
//  Copyright © 2016年 酌晨茗. All rights reserved.
//

#import "UploadFile.h"

@implementation UploadFile

- (void)uploadFileWithURLString:(NSString *)urlstring
                      parameter:(NSString *)parameter
                       fileData:(NSData *)filedata
                       fileName:(NSString *)fileName
                            dic:(NSDictionary *)dic {
    
    NSString *TWITTERFON_FORM_BOUNDARY = @"AaB03x";
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlstring] cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:10];
    //分界线 --AaB03x
    NSString *MPboundary = [[NSString alloc] initWithFormat:@"--%@", TWITTERFON_FORM_BOUNDARY];
    //结束符 AaB03x--
    NSString *endMPboundary = [[NSString alloc] initWithFormat:@"%@--", MPboundary];
    //要上传的文件
    NSData *data = [NSData dataWithData:filedata];
    
    //http body的字符串
    NSMutableString *body = [[NSMutableString alloc] init];
    //参数的集合普通的key－value参数
    
    //    body = [self setParamsKey:@"uptype" value:@"1" body:body];
    //    body = [self setParamsKey:@"sid" value:msgId body:body];
    //    body = [self setParamsKey:@"uid" value:userid body:body];
    //
    NSArray *keys = [dic allKeys];
    
    //遍历keys
    for(int i = 0; i < [keys count]; i++) {
        //得到当前key value
        NSString *key = [keys objectAtIndex:i];
        NSString *value = [dic valueForKey:key];
        
        //添加分界线，换行
        body = [self setParamsKey:key value:value body:body];
    }
    
    ////添加分界线，换行
    [body appendFormat:@"%@\r\n", MPboundary];
    //声明文件字段，文件名
    [body appendFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"%@\"\r\n", parameter, fileName];
    //声明上传文件的格式
    [body appendFormat:@"Content-Type: %@\r\n\r\n", [self getContentType:fileName]];
    
    //声明结束符：--AaB03x--
    NSString *end = [[NSString alloc] initWithFormat:@"\r\n%@", endMPboundary];
    //声明myRequestData，用来放入http body
    NSMutableData *myRequestData = [NSMutableData data];
    //将body字符串转化为UTF8格式的二进制
    [myRequestData appendData:[body dataUsingEncoding:NSUTF8StringEncoding]];
    //将file的data加入
    [myRequestData appendData:data];
    //加入结束符--AaB03x--
    [myRequestData appendData:[end dataUsingEncoding:NSUTF8StringEncoding]];
    
    //设置HTTPHeader中Content-Type的值
    NSString *content = [[NSString alloc] initWithFormat:@"multipart/form-data; boundary=%@",TWITTERFON_FORM_BOUNDARY];
    //设置HTTPHeader
    [request setValue:content forHTTPHeaderField:@"Content-Type"];
    //设置Content-Length
    [request setValue:[NSString stringWithFormat:@"%ld", [myRequestData length]] forHTTPHeaderField:@"Content-Length"];
    //设置http body
    [request setHTTPBody:myRequestData];
    //http method
    [request setHTTPMethod:@"POST"];
    
    //开线程下载
    NSURLSessionConfiguration *conf = [NSURLSessionConfiguration ephemeralSessionConfiguration];
    NSURLSession *urlsessiont = [NSURLSession sessionWithConfiguration:conf];
    __block UploadFile *weakself = self;
    NSURLSessionDataTask *dataTask = [urlsessiont dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakself.delegate finisheWithData:data];
        });
    }];
    [dataTask resume];
}

- (void)uploadFileWithURLString:(NSString *)urlstring
                 parameterArray:(NSArray *)parameterArray
                  fileDataArray:(NSArray *)filedataArray
                  fileNameArray:(NSArray *)fileNameArray
                            dic:(NSDictionary *)dic {
    NSString *TWITTERFON_FORM_BOUNDARY = @"AaB03x";
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlstring] cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:10];
    
    //分界线 --AaB03x
    NSString *MPboundary = [[NSString alloc] initWithFormat:@"--%@", TWITTERFON_FORM_BOUNDARY];
    //结束符 AaB03x--
    NSString *endMPboundary = [[NSString alloc] initWithFormat:@"%@--", MPboundary];

    //http body的字符串
    NSMutableString *body = [[NSMutableString alloc] init];
    //参数的集合普通的key－value参数
    
    NSArray *keys = [dic allKeys];
    //遍历keys
    for(int i = 0; i < [keys count]; i++) {
        //得到当前key value
        NSString *key = [keys objectAtIndex:i];
        NSString *value = [dic valueForKey:key];
        //添加分界线，换行
        body = [self setParamsKey:key value:value body:body];
    }
    
    //声明myRequestData，用来放入http body
    NSMutableData *myRequestData = [NSMutableData data];
    
    for (int i = 0; i < parameterArray.count; i++) {
        NSData *data = [NSData dataWithData:filedataArray[i]];
        ////添加分界线，换行
        [body appendFormat:@"%@\r\n", MPboundary];
        //声明文件字段，文件名
        [body appendFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"%@\"\r\n", parameterArray[i], fileNameArray[i]];
        //声明上传文件的格式
        [body appendFormat:@"Content-Type: %@\r\n\r\n", [self getContentType:fileNameArray[i]]];
        
        //将body字符串转化为UTF8格式的二进制
        [myRequestData appendData:[body dataUsingEncoding:NSUTF8StringEncoding]];
        //将file的data加入
        [myRequestData appendData:data];
    }
    
    //声明结束符：--AaB03x--
    NSString *end = [[NSString alloc] initWithFormat:@"\r\n%@", endMPboundary];
    //加入结束符--AaB03x--
    [myRequestData appendData:[end dataUsingEncoding:NSUTF8StringEncoding]];
    
    //设置HTTPHeader中Content-Type的值
    NSString *content = [[NSString alloc] initWithFormat:@"multipart/form-data; boundary=%@",TWITTERFON_FORM_BOUNDARY];
    
    //设置HTTPHeader
    [request setValue:content forHTTPHeaderField:@"Content-Type"];
    //设置Content-Length
    [request setValue:[NSString stringWithFormat:@"%ld", [myRequestData length]] forHTTPHeaderField:@"Content-Length"];
    //设置http body
    [request setHTTPBody:myRequestData];
    //http method
    [request setHTTPMethod:@"POST"];
    
    NSURLSessionConfiguration *conf = [NSURLSessionConfiguration ephemeralSessionConfiguration];
    NSURLSession *urlsessiont = [NSURLSession sessionWithConfiguration:conf];
    __block UploadFile *weakself = self;
    NSURLSessionDataTask *dataTask = [urlsessiont dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakself.delegate finisheWithData:data];
        });
    }];
    [dataTask resume];
}

- (NSMutableString *)setParamsKey:(NSString *)key value:(NSString *)value body:(NSMutableString *)body {
    NSString *TWITTERFON_FORM_BOUNDARY = @"AaB03x";
    //分界线 --AaB03x
    NSString *MPboundary = [[NSString alloc] initWithFormat:@"--%@", TWITTERFON_FORM_BOUNDARY];
    //添加分界线，换行
    [body appendFormat:@"%@\r\n", MPboundary];
    //添加字段名称，换2行
    [body appendFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", key];
    //添加字段的值
    [body appendFormat:@"%@\r\n", value];
    return body;
}

#pragma mark - 获得网页上传类型
- (NSString *)getContentType:(NSString *)filename {
    if ([filename hasSuffix:@".avi"]) {
        return @"video/avi";
    } else if([filename hasSuffix:@".bmp"]) {
        return @"application/x-bmp";
    } else if([filename hasSuffix:@"jpeg"]) {
        return @"image/jpeg";
    } else if([filename hasSuffix:@"jpg"]) {
        return @"image/jpeg";
    } else if([filename hasSuffix:@"png"]) {
        return @"image/x-png";
    } else if([filename hasSuffix:@"mp3"]) {
        return @"audio/mp3";
    } else if([filename hasSuffix:@"mp4"]) {
        return @"video/mpeg4";
    } else if([filename hasSuffix:@"rmvb"]) {
        return @"application/vnd.rn-realmedia-vbr";
    } else if([filename hasSuffix:@"txt"]) {
        return @"text/plain";
    } else if([filename hasSuffix:@"xsl"]) {
        return @"application/x-xls";
    } else if([filename hasSuffix:@"xslx"]) {
        return @"application/x-xls";
    } else if([filename hasSuffix:@"xwd"]) {
        return @"application/x-xwd";
    } else if([filename hasSuffix:@"doc"]) {
        return @"application/msword";
    } else if([filename hasSuffix:@"docx"]) {
        return @"application/msword";
    } else if([filename hasSuffix:@"ppt"]) {
        return @"application/x-ppt";
    } else if([filename hasSuffix:@"pdf"]) {
        return @"application/pdf";
    } else if ([filename hasSuffix:@"aac"]) {
        return @"audio/aac";
    }
    return nil;
}


@end
