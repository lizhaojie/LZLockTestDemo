//
//  ViewController.m
//  LockTestDemo
//
//  Created by lizhaojie on 17/1/11.
//  Copyright © 2017年 siemens. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
{
    NSLock *lock;
    NSRecursiveLock *recursiveLock;
    //@synchronized
    NSThread *thread;
    
}
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self useNSLock];
    
    // Do any additional setup after loading the view, typically from a nib.
}
/*
 
 NSLock上锁和释放锁这两个操作务必要在同一个线程里，否则会会出错
 [NSLock unlock]: lock (<NSLock: 0xxxxxxxxxxxxx>) '(null)' unlocked from thread which did not lock it
 死锁，同一把锁还未解锁又去枷锁就会造成死锁：deadLock
 */
- (void)useNSLock{
    lock = [[NSLock alloc] init];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSLog(@"线程1尝试加锁！");
        [lock lock];
        sleep(3);
        NSLog(@"thread1");
        [lock unlock];
        NSLog(@"线程1解锁成功！");
    });
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSLog(@"线程2尝试加锁！");
        BOOL getLock = [lock lockBeforeDate:[NSDate dateWithTimeIntervalSinceNow:3]];
        if (getLock) {
            NSLog(@"thread2");
            [lock unlock];
            NSLog(@"线程2解锁成功！");

        }else{
            NSLog(@"获取锁失败！");
        }
       

    });
    
    
}
/*
 
 
 
 */
- (void)use{
    recursiveLock = [NSRecursiveLock new];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
       
        void (^recursiveBlock)(int);
        recursiveBlock = ^(int value){
            [recursiveLock lock];
            if (value>0) {
                NSLog(@"第%d次枷锁",value);
                recursiveBlock(value-1);
            }
            [recursiveLock unlock];

        };
        
    });
}
/*
 @synchronize关键字的条件锁(object)是互斥的标识，只有object是同一个才会产生互斥：
 优点：不用手动创建锁就可以实现锁机制
 缺点：但作为一种预防措施，@synchronized块会隐式的添加一个异常处理例程来保护代码，该处理例程会在异常抛出的时候自动的释放互斥锁，会带来额外的开销
 */
- (void)useSynchronized{
    //线程1
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        @synchronized (self) {
            sleep(2);
            NSLog(@"线程1");
        }
    });
    
    //线程2
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        @synchronized (self) {
            NSLog(@"线程2");
        }
    });
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
