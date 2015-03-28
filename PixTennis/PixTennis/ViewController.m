//
//  ViewController.m
//  PixTennis
//
//  Created by GrandSteph on 3/18/15.
//  Copyright (c) 2015 GrandSteph. All rights reserved.
//

#import "ViewController.h"
#import "AppDelegate.h"

@interface ViewController ()
- (IBAction)sendMessage:(id)sender;
@property (strong, nonatomic) IBOutlet UILabel *message;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(inviteReceived:) name:@"message" object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)sendMessage:(id)sender {
    
    NSDate *sendTime = [NSDate date];
    NSDate __block *receivedTime;
    
    [PubNub sendMessage:@{@"text":[NSString stringWithFormat:@"%@",[NSDate date]]} toChannel:[PNChannel channelWithName:@"StephaneChannel"] withCompletionBlock:^(PNMessageState state, id data) {
        
        switch (state) {
            case PNMessageSending:
                NSLog(@"message sent");
                
                break;
            case PNMessageSendingError:
                NSLog(@"message error");
                
                break;
            case PNMessageSent:
                NSLog(@"message sent");
                receivedTime = [NSDate date];
                
                break;
            default:
                break;
        }
    }];
    NSTimeInterval latency = [receivedTime timeIntervalSinceDate:sendTime];
    
    NSLog(@"\n\n\n\n Interval %f \n\n\n\n",latency);
    
    //[PubNub updateClientState:@"Stephane" state:@{@"appState":@"ONLINE",@"userNickname":@"Stephane"} forObject:[PNChannel channelWithName:@"Stephane"]];

}

- (void)requestParticipantsListWithClientIdentifiers:(BOOL)isClientIdentifiersRequired
                                         clientState:(BOOL)shouldFetchClientState
                                  andCompletionBlock:(PNClientParticipantsHandlingBlock)handleBlock {
    
}

- (void) inviteReceived:(NSNotification *) notification {
    
    NSDictionary *messageContent = [NSDictionary dictionaryWithDictionary:notification.userInfo];
    
    self.message.text = [NSString stringWithFormat:@"%@ - %@",[messageContent objectForKey:@"text"],[NSDate date]];

    
    [PubNub requestParticipantsListWithClientIdentifiers:YES clientState:YES andCompletionBlock:^(PNHereNow *presenceInformation, NSArray *channels, PNError *error) {
        NSLog(@"");
    }];
}


@end
