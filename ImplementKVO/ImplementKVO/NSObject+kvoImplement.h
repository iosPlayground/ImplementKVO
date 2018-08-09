//
//  NSObject+kvoImplement.h
//  ImplementKVO
//
//  Created by suyao on 2018/8/9.
//  Copyright © 2018 suyao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IPKVOInfo.h"

@interface NSObject (kvoImplement)

- (void)ip_addObserver:(id)observer forKeyPath:(NSString *)keyPath options:(IPKeyValueObservingOptions)options context:(void *)context;

- (void)ip_removeObserver:(nonnull NSObject *)object forKeyPath:(nonnull NSString *)keyPath;

@end
