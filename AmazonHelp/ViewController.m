//
//  ViewController.m
//  AmazonHelp
//
//  Created by Sekorm on 2017/5/2.
//  Copyright © 2017年 YL. All rights reserved.
//

#import "ViewController.h"
#import <WebKit/WebKit.h>

#define UKUrlStr @"https://www.amazon.co.uk/s/ref=nb_sb_noss?url=search-alias%3Daps&field-keywords="
@interface ViewController () <WKNavigationDelegate>

@property (nonatomic,strong) WKWebView *webView;
@property (nonatomic,copy) NSString *urlStr;
@property (nonatomic,strong) NSArray *dataArray;

@end

@implementation ViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.urlStr = UKUrlStr;
    
    //    NSString *htmlStr = @"of 41995 results adssfd of 41,995 results";
    //    NSString *regexString = @"of+\\s+(?<=\d)(?=(\d{3})+$)+\\s+results";
    //    NSString *htmlStr = @"of 41995 results adssfd of 1,995 results  of 995 results";
    NSString *pathStr = @"/Users/yaozhong/Desktop/keyword.txt";
    self.dataArray = [self readFile:pathStr];
    
    //1.获得全局的并发队列
    dispatch_queue_t queue =  dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    //2.添加任务到队列中，就可以执行任务
    //异步函数：具备开启新线程的能力
    
    dispatch_async(queue, ^{

        NSMutableString *totalStr = [NSMutableString string];
        
        for (NSInteger i = 0; i < self.dataArray.count; i++) {
            
            NSString *str = self.dataArray[i];
            NSString *tempStr = [str stringByReplacingOccurrencesOfString:@" " withString:@"+"];
            NSURL *URL = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",self.urlStr,tempStr]];
            NSString *htmlStr = [[NSString alloc] initWithContentsOfURL:URL encoding:NSUTF8StringEncoding error:nil];
            if (htmlStr.length == 0) {
                //NSString *dataStr = [NSString stringWithFormat:@"%@ = 0 \n",str];
                NSString *dataStr = @"0\n";
                [totalStr appendString:dataStr];
                continue;
            }
            
            NSString *regexString = @"[1-9][0-9]{0,2}((,[0-9]{3})*)+\\s+results+\\s+for";
            NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:regexString options:NSRegularExpressionCaseInsensitive error:nil];
            NSTextCheckingResult *checkResult = [regex firstMatchInString:htmlStr options:NSMatchingReportCompletion range:NSMakeRange(0, htmlStr.length)];
            NSString *checkText = [htmlStr substringWithRange:[checkResult rangeAtIndex:0]];
            NSArray *resultTextArray = [checkText componentsSeparatedByString:@" "];
            if (resultTextArray.count > 0) {

//                NSString *dataStr = [NSString stringWithFormat:@"%@ = %@\n",str,resultTextArray.firstObject];
                NSString *dataStr = [NSString stringWithFormat:@"%@\n",resultTextArray.firstObject];
                [totalStr appendString:dataStr];
            }else {
                {
                    //NSString *dataStr = [NSString stringWithFormat:@"%@ = 0 \n",str];
                    NSString *dataStr = @"0\n";
                    [totalStr appendString:dataStr];
                    continue;
                }

            }
        }
        
        NSString *targtPath = @"/Users/yaozhong/Desktop/result.txt";
        [totalStr writeToFile:targtPath atomically:YES encoding:NSUTF8StringEncoding error:nil];
        NSLog(@"写入完成");
        
    });
}


//读取文件
- (NSArray *)readFile:(NSString *)path{
    NSError *error = nil;
    NSString *str = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:&error];
    
    if (error != nil) {
        NSLog([error localizedDescription]);//将错误信息输出来
        return nil;
    }
    else{
        return [str componentsSeparatedByString:@"\n"];
        
    }
    
}
@end
