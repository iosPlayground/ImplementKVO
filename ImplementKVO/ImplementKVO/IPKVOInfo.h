//
//  IPKVOInfo.h
//  ImplementKVO
//
//  Created by suyao on 2018/8/9.
//  Copyright © 2018 suyao. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_OPTIONS(NSUInteger, IPKeyValueObservingOptions) {
    
    IPKeyValueObservingOptionNew = 0x01,
    IPKeyValueObservingOptionOld = 0x02,
    IPKeyValueObservingOptionInitial = 0x04,
    IPKeyValueObservingOptionPrior = 0x08,
    
};



@interface IPKVOInfo : NSObject {
    @public void * context;
}
@property (nonatomic, weak) id observer;
@property (nonatomic, assign) IPKeyValueObservingOptions options;

@end
