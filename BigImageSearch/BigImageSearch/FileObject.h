//
//  FileObject.h
//  BigImageSearch
//
//  Created by chenchao on 2018/7/23.
//  Copyright © 2018年 g.10086.cn. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FileObject : NSObject
@property (nonatomic, strong) NSString * filePath;
@property (nonatomic, strong) NSString * fileName;
@property (nonatomic, assign) CGFloat  fileSize;
@end
