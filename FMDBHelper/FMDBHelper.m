//
//  FMDBHelper.m
//  Project
//
//  Created by 姚君 on 15/12/23.
//  Copyright © 2015年 user. All rights reserved.
//

#import "FMDBHelper.h"
#import <FMDB/FMDB.h>
#import <objc/runtime.h>
#import "JSONModel.h"

@interface DBHelperModel : NSObject

@property (nonatomic,strong)NSMutableArray *totalKeys;
@property (nonatomic,strong)NSMutableArray *totalTypes;
@property (nonatomic,strong)NSMutableArray *totalValues;

@end

@implementation DBHelperModel

@end




@interface FMDBHelper ()

@property (nonatomic,strong)FMDatabase *dbDataBase;
@property (nonatomic,strong)DBHelperModel *dbHelperModel;

@end


@implementation FMDBHelper


+ (FMDBHelper *)shareInstance {
    
    static FMDBHelper *instanne;
    
    static dispatch_once_t oneToken;
    
    dispatch_once(&oneToken, ^{
        
        instanne = [[FMDBHelper alloc]init];
        
        [instanne dbDataBase];
        
    });
    
    return instanne;
}

#pragma mark -- Base

- (BOOL)creartTable:(NSString *)name model:(id)model {
    [self analysisPropertiesDependKeys:model];
    
    NSString *sql = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@ (",name];
    if (_dbHelperModel && _dbHelperModel.totalKeys.count > 0) {
        for (int i = 0; i < _dbHelperModel.totalKeys.count; i++) {
            NSArray *totalKeys = [NSArray arrayWithArray:_dbHelperModel.totalKeys];
            NSArray *totalTypes = [NSArray arrayWithArray:_dbHelperModel.totalTypes];
            
            NSString *appendString = [NSString stringWithFormat:@"%@ %@,",totalKeys[i],totalTypes[i]];
            sql = [sql stringByAppendingString:appendString];
        }
        sql = [sql substringToIndex:sql.length-1];
    }
    sql = [sql stringByAppendingString:@")"];
    BOOL b = [self.dbDataBase executeUpdate:sql];
    
    if (!b) {
        NSLog(@"CREATE TABLE %@ 失败！",name);
    }
    return b;
}

- (BOOL)insertInfo:(id)model table:(NSString *)name  {
    
    [self analysisPropertiesDependValues:model];

    NSMutableArray *markArray = [NSMutableArray array];
    for (int i = 0; i < _dbHelperModel.totalKeys.count; i++) {
        [markArray addObject:@"?"];
    }
    NSString *keyString = [_dbHelperModel.totalKeys componentsJoinedByString:@","];
    NSString *valueString = [markArray componentsJoinedByString:@","];
    NSString *sql = [NSString stringWithFormat:@"INSERT INTO %@ (%@) VALUES (%@)",name,keyString,valueString];
    
    BOOL b = [self.dbDataBase executeUpdate:sql withArgumentsInArray:_dbHelperModel.totalValues];
    
    if (!b) {
        NSLog(@"INSERT TABLE %@ INTO %@ 失败！",name,model);
    }
    return b;
}

- (BOOL)updateInfo:(id)model depend:(NSDictionary *)dic table:(NSString *)name{
    [self analysisPropertiesDependValues:model];
    
    NSMutableArray *arr = [NSMutableArray array];
    
    NSString *sql = [NSString stringWithFormat:@"UPDATE %@ SET ",name];
    if (_dbHelperModel && _dbHelperModel.totalKeys.count > 0) {
        for (int i = 0; i < _dbHelperModel.totalKeys.count; i++) {
            
            NSString *mkey = _dbHelperModel.totalKeys[i];
            id mvalue = [model valueForKey:mkey];
            
            if ([mvalue isEqual:[NSNull null]] || ([mvalue isKindOfClass:[NSString class]] && ((NSString *)mvalue).length == 0)|| ([mvalue isKindOfClass:[NSNumber class]] && ((NSNumber *)mvalue).floatValue == 0)) {
                
            }else {
                sql = [sql stringByAppendingString:[NSString stringWithFormat:@" %@ = ?",mkey]];
                if (i != _dbHelperModel.totalKeys.count-1) {
                    sql = [sql stringByAppendingString:@" , "];
                }
                
                [arr addObject:mvalue];
            }
        }
    }
    //更新条件
    sql = [sql stringByAppendingString:@" WHERE "];

    NSArray *depKeys = [dic allKeys];
    for (int i = 0; i < depKeys.count; i++) {
        NSString *depKey = depKeys[i];
        sql = [sql stringByAppendingString:[NSString stringWithFormat:@" %@ = '%@'",depKey,dic[depKey]]];
        if (i != depKeys.count-1) {
            sql = [sql stringByAppendingString:@" AND "];
        }
    }
    BOOL b = [self.dbDataBase executeUpdate:sql withArgumentsInArray:arr];
    
    if (!b) {
        NSLog(@"UPDATE TABLE %@ 失败！",name);
    }
    return b;
}

- (BOOL)deleteInfo:(id)model depend:(NSDictionary *)dic table:(NSString *)name {
    
    NSString *sql = [NSString stringWithFormat:@"DELETE FROM %@ ",name];

    //条件
    sql = [sql stringByAppendingString:@" WHERE "];
    
    NSArray *depKeys = [dic allKeys];
    for (int i = 0; i < depKeys.count; i++) {
        NSString *depKey = depKeys[i];
        sql = [sql stringByAppendingString:[NSString stringWithFormat:@" %@ = '%@'",depKey,dic[depKey]]];
        if (i != depKeys.count-1) {
            sql = [sql stringByAppendingString:@" AND "];
        }
    }
    BOOL b = [self.dbDataBase executeUpdate:sql];
    
    if (!b) {
        NSLog(@"DELETE FROM TABLE %@ 失败！",name);
    }
    return b;
}

- (id)findInfo:(id)model depend:(NSDictionary *)dic table:(NSString *)name {
    [self analysisPropertiesDependKeys:model];
    
    NSString *keyString = [_dbHelperModel.totalKeys componentsJoinedByString:@","];

    NSString *sql = [NSString stringWithFormat:@"SELECT %@ FROM %@",keyString,name];

    //条件
    sql = [sql stringByAppendingString:@" WHERE "];
    
    NSArray *depKeys = [dic allKeys];
    for (int i = 0; i < depKeys.count; i++) {
        NSString *depKey = depKeys[i];
        sql = [sql stringByAppendingString:[NSString stringWithFormat:@" %@ = '%@'",depKey,dic[depKey]]];
        if (i != depKeys.count-1) {
            sql = [sql stringByAppendingString:@" AND "];
        }
    }
    //结果解析
    FMResultSet *set = [self.dbDataBase executeQuery:sql];
    while ([set next]) {
        NSMutableDictionary *tempDic = [NSMutableDictionary dictionary];
        for (int i = 0; i < _dbHelperModel.totalKeys.count; i++) {
            NSString *type = _dbHelperModel.totalTypes[i];
            NSString *key = _dbHelperModel.totalKeys[i];
            
            if ([type isEqualToString:@"text"]) {
                NSString *obj = [set stringForColumn:key];
                [tempDic setValue:obj forKey:_dbHelperModel.totalKeys[i]];
                
            }else if ([type isEqualToString:@"integer"]) {
                NSInteger obj = [set longLongIntForColumn:key];
                [tempDic setValue:[NSNumber numberWithInteger:obj] forKey:_dbHelperModel.totalKeys[i]];
                
            }else if ([type isEqualToString:@"bool"]) {
                BOOL obj = [set boolForColumn:key];
                [tempDic setValue:[NSNumber numberWithBool:obj] forKey:_dbHelperModel.totalKeys[i]];
                
            }else if ([type isEqualToString:@"float"]) {
                BOOL obj = [set doubleForColumn:key];
                [tempDic setValue:[NSNumber numberWithBool:obj] forKey:_dbHelperModel.totalKeys[i]];
                
            }else if ([type isEqualToString:@"double"]) {
                BOOL obj = [set doubleForColumn:key];
                [tempDic setValue:[NSNumber numberWithBool:obj] forKey:_dbHelperModel.totalKeys[i]];
                
            }
        }
        NSError *error;
        model = [[[model class] alloc] initWithDictionary:[NSDictionary dictionaryWithDictionary:tempDic] error:&error];
        NSLog(@"error = %@",error);
        NSLog(@"find model %@ ！",model);
        
        return model;
    }
    
    return nil;

}

- (BOOL)deleteTable:(NSString *)name {
    
    NSString *sql = [NSString stringWithFormat:@"DROP TABLE %@ ",name];
    
    BOOL b = [self.dbDataBase executeUpdate:sql];
    
    if (!b) {
        NSLog(@"DELETE TABLE %@ 失败！",name);
    }
    return b;
}

- (BOOL)checkSameInfo:(id)model depend:(NSDictionary *)dic table:(NSString *)name {

    [self analysisPropertiesDependKeys:model];
    
    NSString *keyString = [_dbHelperModel.totalKeys componentsJoinedByString:@","];
    
    NSString *sql = [NSString stringWithFormat:@"SELECT %@ FROM %@",keyString,name];
    
    //条件
    sql = [sql stringByAppendingString:@" WHERE "];
    
    NSArray *depKeys = [dic allKeys];
    for (int i = 0; i < depKeys.count; i++) {
        NSString *depKey = depKeys[i];
        sql = [sql stringByAppendingString:[NSString stringWithFormat:@" %@ = '%@'",depKey,dic[depKey]]];
        if (i != depKeys.count-1) {
            sql = [sql stringByAppendingString:@" AND "];
        }
    }
    //结果
    FMResultSet *set = [self.dbDataBase executeQuery:sql];
    while ([set next]) {
        NSString *identifier = [set stringForColumn:@"identifier"];
        if (![identifier isEqual:[NSNull null]] && identifier) {
            return YES;
        }
        
    }
    return NO;
}

#pragma mark -- Auxiliary

- (void)paraTypeString:(NSString *)typeString {

//    NSLog(@"typeString=%@",typeString);
    if ([typeString isEqualToString:@"T@'NSString'"]) {
        [_dbHelperModel.totalTypes addObject:@"text"];
    }else if ([typeString isEqualToString:@"TQ"]) {
        [_dbHelperModel.totalTypes addObject:@"integer"];
    }else if ([typeString isEqualToString:@"TB"]) {
        [_dbHelperModel.totalTypes addObject:@"bool"];
    }else if ([typeString isEqualToString:@"Tf"]) {
        [_dbHelperModel.totalTypes addObject:@"float"];
    }else if ([typeString isEqualToString:@"Td"]) {
        [_dbHelperModel.totalTypes addObject:@"double"];
    }else {
        [_dbHelperModel.totalTypes addObject:@"text"];
    }

}

- (void)analysisPropertiesDependValues:(id)model {

    self.dbModel.totalKeys = [NSMutableArray arrayWithCapacity:0];
    self.dbModel.totalTypes = [NSMutableArray arrayWithCapacity:0];
    self.dbModel.totalValues = [NSMutableArray arrayWithCapacity:0];

    unsigned int outCount,i;
    objc_property_t *properties = class_copyPropertyList([model class], &outCount);
    for (i = 0; i < outCount; i++) {
        objc_property_t property = properties[i];
        NSString *propertyKey = [[NSString alloc]initWithCString:property_getName(property) encoding:NSUTF8StringEncoding];
        id propertyValue = [model valueForKey:propertyKey];
        if (propertyValue) {
            
            [_dbHelperModel.totalKeys addObject:propertyKey];
            [_dbHelperModel.totalValues addObject:propertyValue];
            
            const char *attributes = property_getAttributes(property);
            NSString * attributeString = [NSString stringWithUTF8String:attributes];
            NSArray * attributesArray = [attributeString componentsSeparatedByString:@","];
            NSString *typeString = [attributesArray firstObject];
            
            [self paraTypeString:typeString];
        }
    }
}

- (void)analysisPropertiesDependKeys:(id)model {
    
    self.dbModel.totalKeys = [NSMutableArray arrayWithCapacity:0];
    self.dbModel.totalTypes = [NSMutableArray arrayWithCapacity:0];
    self.dbModel.totalValues = [NSMutableArray arrayWithCapacity:0];

    unsigned int outCount,i;
    objc_property_t *properties = class_copyPropertyList([model class], &outCount);
    for (i = 0; i < outCount; i++) {
        objc_property_t property = properties[i];
        NSString *propertyKey = [[NSString alloc]initWithCString:property_getName(property) encoding:NSUTF8StringEncoding];
        [_dbHelperModel.totalKeys addObject:propertyKey];
        
        const char *attributes = property_getAttributes(property);
        NSString * attributeString = [NSString stringWithUTF8String:attributes];
        NSArray * attributesArray = [attributeString componentsSeparatedByString:@","];
        NSString *typeString = [attributesArray firstObject];
        
        [self paraTypeString:typeString];
    }
}

- (FMDatabase *)dbDataBase {
    
    if (!_dbDataBase) {
        
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentationDirectory, NSUserDomainMask, YES);
        
        NSString *dbPath = [[paths firstObject] stringByAppendingPathComponent:@"DB"];
        
        if (![[NSFileManager defaultManager] fileExistsAtPath:dbPath]) {
            
            [[NSFileManager defaultManager] createDirectoryAtPath:dbPath withIntermediateDirectories:YES attributes:nil error:nil];
        }
        
        NSString *mydbPath = [dbPath stringByAppendingPathComponent:@"MyDataBase.db"];
        
        NSLog(@"%@",mydbPath);
        _dbDataBase = [FMDatabase databaseWithPath:mydbPath];
    }
    if (![_dbDataBase open]) {
        
        NSLog(@"无法打开DB");
    }
    
    return _dbDataBase;
}

- (DBHelperModel *)dbModel {

    if (!_dbHelperModel) {
        
        _dbHelperModel = [[DBHelperModel alloc]init];
    }
    return _dbHelperModel;
}


@end
