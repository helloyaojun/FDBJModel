//
//  Model2.h
//  FDBJModel
//
//  Created by 姚君 on 15/12/25.
//  Copyright © 2015年 coco. All rights reserved.
//

#import <JSONModel/JSONModel.h>

@interface Model2 : JSONModel

@property (nonatomic,assign)NSUInteger mySecondId;
@property (nonatomic,strong)NSString *mySecondName;
@property (nonatomic,assign)NSUInteger mySecondAge;

@end
