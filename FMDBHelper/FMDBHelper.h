//
//  FMDBHelper.h
//  Project
//
//  Created by 姚君 on 15/12/23.
//  Copyright © 2015年 user. All rights reserved.
//
/*
 可用于简单的数据库处理。如果建议，欢迎联系我，QQ：2845569128
 */

#import <Foundation/Foundation.h>

@interface FMDBHelper : NSObject

+ (FMDBHelper *)shareInstance;

- (BOOL)deleteTable:(NSString *)name;

- (BOOL)creartTable:(NSString *)name model:(id)model;

- (BOOL)insertInfo:(id)model table:(NSString *)name;

- (BOOL)updateInfo:(id)model depend:(NSDictionary *)dic table:(NSString *)name;

- (BOOL)deleteInfo:(id)model depend:(NSDictionary *)dic table:(NSString *)name;

- (id)findInfo:(id)model depend:(NSDictionary *)dic table:(NSString *)name;

@end
