//
//  ViewController.m
//  socketTest
//
//  Created by Damon on 15/10/28.
//  Copyright © 2015年 zhangle.in.iMac. All rights reserved.
//

#import "ViewController.h"
#import "GlobalInfo.h"
#import "CocoaAsyncSocket.h"

@interface ViewController ()<AsyncSocketDelegate, UITextFieldDelegate>
{
    __weak IBOutlet UITextField *ipTf;
    __weak IBOutlet UITextField *portTf;
    __weak IBOutlet UITextView *textView;
    NSString *ipStr;
    NSString *portStr;
    AsyncSocket *socket;
    BOOL isChangeValue;
}
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    if ([GlobalInfo getUserDefaults:@"ip"])
    {
        ipTf.text = [GlobalInfo getUserDefaults:@"ip"];
    }
    if ([GlobalInfo getUserDefaults:@"port"])
    {
        portTf.text = [GlobalInfo getUserDefaults:@"port"];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if ([textField isEqual:ipTf])
    {
        [ipTf resignFirstResponder];
        [portTf becomeFirstResponder];
    }
    else if([textField isEqual:portTf])
    {
        [portTf resignFirstResponder];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self connectAction:nil];
        });
    }
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if ([textField isEqual:ipTf])
    {
        if (!ipStr)
        {
            ipStr = ipTf.text;
        }
    }
    else if([textField isEqual:portTf])
    {
        if (!portStr)
        {
            portStr = portTf.text;
        }
    }
}

- (IBAction)connectAction:(UIButton *)sender {
    if ([ipTf.text isEqualToString:@""])
    {
        [GlobalInfo alertViewShow:@"请输入正确的ip地址" delegate:nil];
        return;
    }
    if ([portTf.text isEqualToString:@""])
    {
        [GlobalInfo alertViewShow:@"请输入正确的端口" delegate:nil];
        return;
    }
    if ((ipStr && [ipStr isEqualToString:ipTf.text]) || (portStr && [portStr isEqualToString:portTf.text]))
    {
        isChangeValue = NO;
    }
    else
    {
        isChangeValue = YES;
        ipStr = ipTf.text;
        portStr = portTf.text;
    }
    [self connetToAsyncSocket];
}

- (void)connetToAsyncSocket
{
    if (!isChangeValue && [socket isConnected])
    {
        [GlobalInfo alertViewShow:@"已经连接服务器端口" delegate:nil];
        return;
    }
    textView.text = @"";
    socket = [[AsyncSocket alloc] initWithDelegate:self];
    NSError *error = nil;
    [socket connectToHost:ipTf.text onPort:[portTf.text intValue]  error:&error];
    if (error)
    {
        NSLog(@"error = %@", error);
    }
    [GlobalInfo setUserDefaults:ipStr name:@"ip"];
    [GlobalInfo setUserDefaults:portStr name:@"port"];
    [socket readDataWithTimeout:-1 tag:1000];
}

- (void)onSocket:(AsyncSocket *)sock didConnectToHost:(NSString *)host port:(UInt16)port
{
    NSString *remoteAddress = [NSString stringWithFormat:@"host = %@, port = %d", host, port];
    NSString *localAddress = [NSString stringWithFormat:@"localhost = %@, port = %d", sock.localHost, sock.localPort];
    textView.text = [textView.text stringByAppendingString:[NSString stringWithFormat:@"%@\n%@\n", remoteAddress, localAddress]];
}

- (void)onSocket:(AsyncSocket *)sock willDisconnectWithError:(NSError *)err
{
    if (err)
    {
        NSString *errorStr = [err localizedFailureReason];
        textView.text = [textView.text stringByAppendingString:[NSString stringWithFormat:@"错误连接信息:%@", errorStr]];
    }
}

- (void)onSocketDidDisconnect:(AsyncSocket *)sock
{
    textView.text = [textView.text stringByAppendingString:[NSString stringWithFormat:@"连接断开"]];
}


- (void)onSocket:(AsyncSocket *)sock didReadPartialDataOfLength:(NSUInteger)partialLength tag:(long)tag
{
    textView.text = [textView.text stringByAppendingString:[NSString stringWithFormat:@"分段读取:%ld, tag = %ld", partialLength, tag]];
}

- (BOOL)onSocketWillConnect:(AsyncSocket *)sock
{
    return YES;
}



- (void)onSocket:(AsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
    NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"服务端的数据 -> %@", str);
    textView.text = [textView.text stringByAppendingString:[NSString stringWithFormat:@"%@\n", str]];
    //跳转到最新的数据
    [textView scrollRangeToVisible:NSMakeRange(textView.text.length - str.length, str.length)];
    [sock readDataWithTimeout:-1 tag:100];
}

- (IBAction)closeAction:(UIButton *)sender {
    [socket disconnectAfterReadingAndWriting];
}



@end
