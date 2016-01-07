//
//  Model1.h
//  FDBJModel
//
//  Created by 姚君 on 15/12/25.
//  Copyright © 2015年 coco. All rights reserved.
//

#import <JSONModel/JSONModel.h>

@interface Model1 : JSONModel

@property (nonatomic,assign)NSUInteger myId;
@property (nonatomic,strong)NSString *myName;
@property (nonatomic,assign)NSUInteger myAge;

@end
