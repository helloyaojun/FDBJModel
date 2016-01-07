//
//  ViewController.m
//  FDBJModel
//
//  Created by 姚君 on 15/12/25.
//  Copyright © 2015年 coco. All rights reserved.
//

#import "ViewController.h"
#import "FMDBHelper.h"
#import "Model1.h"
#import "Model2.h"

@interface ViewController () {

    NSUInteger tableindex;
    NSInteger infoindex;

}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    UIView *view = [[[NSBundle mainBundle]loadNibNamed:@"View" owner:self options:nil] lastObject];
    [self.view addSubview:view];
    
    tableindex = 1;
    infoindex = 1;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)addtable:(id)sender {
    
    if (tableindex == 0) {
        tableindex = 1;
    }else {
        tableindex = 0;
    }
    id model;
    if (tableindex % 2 == 1) {
        model = [Model1 new];
    }else {
        model = [Model2 new];
    }
    [[FMDBHelper shareInstance]creartTable:[NSString stringWithFormat:@"Table%ld",tableindex] model:model];
}

- (IBAction)addinfo:(id)sender {
    
    if (tableindex % 2 == 1) {
        infoindex++;

        Model1 *model = [[Model1 alloc]init];
        model.myId = infoindex;
        model.myAge = 26;
        model.myName = @"coco";
        [[FMDBHelper shareInstance]insertInfo:model table:[NSString stringWithFormat:@"Table%ld",tableindex]];

    }else {
        infoindex--;

        Model2 *model = [[Model2 alloc]init];
        model.mySecondId = infoindex;
        model.mySecondAge = 27;
        model.mySecondName = @"yaojun";
        [[FMDBHelper shareInstance]insertInfo:model table:[NSString stringWithFormat:@"Table%ld",tableindex]];
    }

}

- (IBAction)updateinfo:(id)sender {
    
    if (tableindex % 2 == 1) {
        
        Model1 *model = [[Model1 alloc]init];
        model.myAge = 18;
        model.myName = @"coco";
        [[FMDBHelper shareInstance] updateInfo:model depend:@{@"myName":@"coco"} table:[NSString stringWithFormat:@"Table%ld",tableindex]];
        
    }else {
        
        Model2 *model = [[Model2 alloc]init];
        model.mySecondAge = 16;
        model.mySecondName = @"yaojun";
        [[FMDBHelper shareInstance] updateInfo:model depend:@{@"mySecondName":@"yaojun"} table:[NSString stringWithFormat:@"Table%ld",tableindex]];
    }

}

- (IBAction)deleteinfo:(id)sender {
    
    if (tableindex % 2 == 1) {
        infoindex--;
        
        Model1 *model = [[Model1 alloc]init];
        NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInteger:infoindex],@"myId", nil];
        [[FMDBHelper shareInstance] deleteInfo:model depend:dic table:[NSString stringWithFormat:@"Table%ld",tableindex]];
        
    }else {
        infoindex++;
        
        Model2 *model = [[Model2 alloc]init];
        NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInteger:infoindex],@"mySecondId", nil];
        [[FMDBHelper shareInstance] deleteInfo:model depend:dic table:[NSString stringWithFormat:@"Table%ld",tableindex]];
    }

}

- (IBAction)findinfo:(id)sender {
    
    if (tableindex % 2 == 1) {
        infoindex--;
        
        Model1 *model = [[Model1 alloc]init];
        NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInteger:infoindex],@"myId", nil];
        model = [[FMDBHelper shareInstance] findInfo:model depend:dic table:[NSString stringWithFormat:@"Table%ld",tableindex]];
        if (model) {
            NSLog(@"找到一条记录%@",model);
        }else {
            NSLog(@"未找到记录");
        }
        
    }else {
        infoindex++;
        
        Model2 *model = [[Model2 alloc]init];
        NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInteger:infoindex],@"mySecondId", nil];
        model = [[FMDBHelper shareInstance] findInfo:model depend:dic table:[NSString stringWithFormat:@"Table%ld",tableindex]];
        if (model) {
            NSLog(@"找到一条记录%@",model);
        }else {
            NSLog(@"未找到记录");
        }

    }
}

- (IBAction)deletetable:(id)sender {
    
    if (tableindex == 0) {
        tableindex = 1;
    }else {
        tableindex = 0;
    }
    [[FMDBHelper shareInstance] deleteTable:[NSString stringWithFormat:@"Table%ld",tableindex]];
}

@end
