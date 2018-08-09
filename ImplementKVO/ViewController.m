//
//  ViewController.m
//  ImplementKVO
//
//  Created by suyao on 2018/8/9.
//  Copyright © 2018 suyao. All rights reserved.
//

#import "ViewController.h"
#import "Person.h"
#import "NSObject+kvoImplement.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    Person *person = [[Person alloc] init];
    [person ip_addObserver:self forKeyPath:@"name" options:IPKeyValueObservingOptionNew | IPKeyValueObservingOptionOld context:@"context 1"];
    [person ip_addObserver:self forKeyPath:@"age" options:IPKeyValueObservingOptionNew | IPKeyValueObservingOptionOld context:@"context 2"];
    person.name = @"Li";
    [person ip_removeObserver:self forKeyPath:@"name"];
    person.name = @"Hao";
    person.age = @"18";
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(Person *)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context{
    NSLog(@"----%@----%@",object.name,object.age);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
