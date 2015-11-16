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
#import "GZIP.h"

@interface ViewController ()<AsyncSocketDelegate, UITextFieldDelegate>
{
    __weak IBOutlet UITextField *ipTf;
    __weak IBOutlet UITextField *portTf;
    __weak IBOutlet UITextView *textView;
    __weak IBOutlet UITextField *userTf;
    __weak IBOutlet UITextField *passTf;
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

- (BOOL)isRightString:(UITextField *)tf alertString:(NSString *)str
{
    BOOL flag = YES;
    if ([tf.text isEqualToString:@""])
    {
        [GlobalInfo alertViewShow:str delegate:nil];
        flag = NO;
    }
    return flag;
}

- (IBAction)connectAction:(UIButton *)sender {
    if ([self isRightString:ipTf alertString:@"请输入IP地址"] || [self isRightString:portTf alertString:@"请输入端口号"] || [self isRightString:userTf alertString:@"请输入用户名"] || [self isRightString:passTf alertString:@"请输入密码"])
    {
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
        textView.text = [textView.text stringByAppendingString:error.localizedDescription];
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
    //发送字符串给服务器进行通讯交互,3145
//    NSString *userName = @"root";
//    NSString *password = @"111111";
//    NSString *companyName = @"上海涨乐互联网科技有限公司";
//    NSString *userEnabled = @"true";
//    NSString *login = [NSString stringWithFormat:@"Login %@,%@,%@,%@\r\n", userName, password, companyName, userEnabled];
//    NSData *data = [login dataUsingEncoding:NSUTF8StringEncoding];
//    [sock writeData:data withTimeout:100.0 tag:1];
}

//socket连接不成功时,需要切换ip地址
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
    //调用gzip库进行解压
    NSData *uncompressData = [data gunzippedData];
    NSLog(@"解压前bytes=%p,length=%ld,解压后bytes=%p,length=%ld",data.bytes, data.length, uncompressData.bytes, uncompressData.length);
    NSString *str = [[NSString alloc] initWithData:uncompressData encoding:NSUTF8StringEncoding];
    NSLog(@"服务端的数据 -> %@", str);
    NSString *typeStr = [[str componentsSeparatedByString:@":"] firstObject];
    if ([typeStr isEqualToString:@"Intime"])
    {
        textView.text = [textView.text stringByAppendingString:@"实时数据:"];
    }
    else if([typeStr isEqualToString:@"History"])
    {
        textView.text = [textView.text stringByAppendingString:@"历史数据:"];
    }
    textView.text = [textView.text stringByAppendingString:[NSString stringWithFormat:@"%@\n", str]];
    //跳转到最新的数据
    [textView scrollRangeToVisible:NSMakeRange(textView.text.length - str.length, str.length)];
    [sock readDataWithTimeout:-1 tag:100];
}

- (IBAction)closeAction:(UIButton *)sender {
//    [socket disconnect];
    [socket disconnectAfterReadingAndWriting];
}



@end
