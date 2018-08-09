//
//  NSObject+kvoImplement.m
//  ImplementKVO
//
//  Created by suyao on 2018/8/9.
//  Copyright © 2018 suyao. All rights reserved.
//


#import <objc/runtime.h>
#import <objc/message.h>
#import "IPKVOInfo.h"

@implementation NSObject (kvoImplement)

- (void)ip_addObserver:(id)observer forKeyPath:(NSString *)keyPath options:(IPKeyValueObservingOptions)options context:(void *)context {
    //动态创建子类
    Class subClass = nil;
    NSString *prefix = [NSString stringWithFormat:@"XnwKVO_"];
    if ([NSStringFromClass([self class]) hasPrefix:prefix]) {
        subClass = [self class];
    }else{
        NSString *subClassName = [prefix stringByAppendingString:NSStringFromClass([self class])];
        subClass = NSClassFromString(subClassName);
        if (!subClass) {
            subClass = objc_allocateClassPair([self class], [subClassName UTF8String], 0);
            objc_registerClassPair(subClass);
        }
    }
    object_setClass(self, subClass);
    //添加方法
    NSString *methodName = [NSString stringWithFormat:@"set%@:", keyPath.localizedCapitalizedString];
    class_addMethod(subClass, NSSelectorFromString(methodName), (IMP)xnwKVO_setValue, "v@:i");
    
    //存储observer
    NSMapTable *mapTable = objc_getAssociatedObject(self, @"observerMap");
    if (!mapTable.count) {
        mapTable = [NSMapTable mapTableWithKeyOptions:NSPointerFunctionsWeakMemory valueOptions:NSPointerFunctionsStrongMemory];
    }
    IPKVOInfo * info = [[IPKVOInfo alloc] init];
    info.observer = observer;
    info.options = options;
    info->context = context;
    
    NSMutableArray * observers = [mapTable objectForKey:keyPath];
    if (!observers) {
        observers = [NSMutableArray array];
        [mapTable setObject:observers forKey:keyPath];
    }
    [observers addObject:info];
    
    objc_setAssociatedObject(self, @"observerMap", mapTable, OBJC_ASSOCIATION_RETAIN);
}

void xnwKVO_setValue(id self,SEL _cmd,id value){
    Class subClass = [self class];
    Class superClass = [self superclass];
    object_setClass(self, superClass);
    
    NSMapTable *mapTable = objc_getAssociatedObject(self, @"observerMap");
    NSString *methodName = NSStringFromSelector(_cmd);
    NSString *keyPath = [methodName substringWithRange:NSMakeRange(3, methodName.length-4)].lowercaseString;
    
    NSMutableArray * observers = [mapTable objectForKey:keyPath];
    [[observers mutableCopy] enumerateObjectsUsingBlock:^(IPKVOInfo *  _Nonnull info, NSUInteger idx, BOOL * _Nonnull stop) {
        id observer = info.observer;
        void * context = info->context;
        IPKeyValueObservingOptions options = info.options;
        
        if (options & IPKeyValueObservingOptionPrior) {
            NSDictionary * change = [NSDictionary dictionaryWithObject:@YES forKey:@"notificationIsPrior"];
            ((void(*)(id,SEL,id,id,id,void*))objc_msgSend)(observer, @selector(observeValueForKeyPath:ofObject:change:context:),keyPath,self,change,context);
        }
        
        Ivar ivar = class_getInstanceVariable([self class], [[@"_" stringByAppendingString:keyPath] UTF8String]);
        id old = object_getIvar(self, ivar);
        id new = value;
        
        ((void(*)(id,SEL,id))objc_msgSend)(self, _cmd,value);
        
        NSMutableDictionary * change = [NSMutableDictionary dictionary];
        
        if (options & IPKeyValueObservingOptionNew) {
            if (new) {
                [change setObject:new forKey:@"new"];
            }else {
                [change setObject:[NSNull null] forKey:@"new"];
            }
        }
        
        if (options & IPKeyValueObservingOptionOld) {
            if (old) {
                [change setObject:old forKey:@"old"];
            }else {
                [change setObject:[NSNull null] forKey:@"old"];
            }
        }
        object_setClass(self, subClass);
        
        if (options & IPKeyValueObservingOptionNew || options & IPKeyValueObservingOptionOld) {
            ((void(*)(id,SEL,id,id,id,void*))objc_msgSend)(observer, @selector(observeValueForKeyPath:ofObject:change:context:),keyPath,self,change,context);
        }
    }];
}

- (void)ip_removeObserver:(nonnull NSObject *)object forKeyPath:(nonnull NSString *)keyPath {
    NSMapTable *mapTable = objc_getAssociatedObject(self, @"observerMap");
    NSMutableArray * observers = [mapTable objectForKey:keyPath];
    [[observers mutableCopy] enumerateObjectsUsingBlock:^(IPKVOInfo *  _Nonnull info, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([info.observer isEqual:object]) {
            [observers removeObject:info];
        }
    }];
}

@end
