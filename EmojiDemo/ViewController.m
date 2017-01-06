//
//  ViewController.m
//  EmojiDemo
//
//  Created by Ian on 12/25/16.
//  Copyright © 2016 iandai. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [self extractEmoji];

    [self testNSStringRemoveEmoji];
}

- (void)extractEmoji {
    
    // convert emoji-test.txt into emoji-test.plist
    NSString* filePath = @"emoji-test";
    NSString* fileRoot = [[NSBundle mainBundle]
                          pathForResource:filePath ofType:@"txt"];
    
    NSLog(@"%@", fileRoot);
    
    // read everything from text
    NSString* fileContents =
    [NSString stringWithContentsOfFile:fileRoot
                              encoding:NSUTF8StringEncoding error:nil];
    
    // first, separate by new line
    NSArray* allLinedStrings =
    [fileContents componentsSeparatedByCharactersInSet:
     [NSCharacterSet newlineCharacterSet]];
    
    int __block count = 0;
    NSMutableArray *results = [[NSMutableArray alloc] init];
    [allLinedStrings enumerateObjectsUsingBlock:^(NSString *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if([obj length] == 0) {
            NSLog(@"here1");
        } else if ([[obj substringToIndex:1] isEqualToString:@"#"]) {
            NSLog(@"here2");
        } else {
            NSString *endStr =
            [[obj componentsSeparatedByCharactersInSet:
              [NSCharacterSet characterSetWithCharactersInString:@"#"]] lastObject];
            NSString *trimedStr = [endStr stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            __block NSString *emoji = @"";
            [trimedStr enumerateSubstringsInRange:NSMakeRange(0, [trimedStr length])
                                          options:NSStringEnumerationByComposedCharacterSequences
                                       usingBlock: ^(NSString* substring, NSRange substringRange, NSRange enclosingRange, BOOL* stop) {
                                           emoji = substring;
                                           *stop = YES;
                                       }];
            [results addObject:emoji];
            count++;
        }
    }];
    
    // save emoji to plist
    NSString *docPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    NSString *filePath1 = [docPath stringByAppendingPathComponent:@"emoji.plist"];
    NSLog(@"file Stored at %@",filePath1);
    [results writeToFile:filePath1 atomically:NO];
}


// Test: https://github.com/woxtu/NSString-RemoveEmoji
- (void)testNSStringRemoveEmoji {
    
    static NSMutableCharacterSet* EmojiCharacterSet = nil;
    EmojiCharacterSet = [[NSMutableCharacterSet alloc] init];
    
    // U+FE00-FE0F (Variation Selectors)
    [EmojiCharacterSet addCharactersInRange:NSMakeRange(0xFE00, 0xFE0F - 0xFE00 + 1)];
    
    // U+2100-27BF
    [EmojiCharacterSet addCharactersInRange:NSMakeRange(0x2100, 0x27BF - 0x2100 + 1)];
    
    // U+1D000-1F9FF
    [EmojiCharacterSet addCharactersInRange:NSMakeRange(0x1D000, 0x1F9FF - 0x1D000 + 1)];
    
    
    NSString* plistName = @"emoji";
    NSString* plistPath = [[NSBundle mainBundle] pathForResource:plistName ofType:@"plist"];
    NSArray *plistArray = [NSArray arrayWithContentsOfFile:plistPath];
    
    for (NSString *aStr in plistArray) {
        NSRange rangeTest = [aStr rangeOfCharacterFromSet:EmojiCharacterSet];
        if(rangeTest.location == NSNotFound) {
            NSLog(@"%@",aStr);
        }
    }
    
    //  output: emoji not included, but should
    //  2B50  ⭐
    //  2B55  ⭕
    //  2B1B  ⬛
    //  2B1C  ⬜
    
}

@end
