//
//  ChatViewController.m
//  Parse Chat
//
//  Created by Khloe Wright on 6/27/22.
//

#import "ChatViewController.h"
#import <Parse/Parse.h>
#import "ChatCell.h"

@interface ChatViewController () <UITableViewDataSource>
@property (strong, nonatomic) IBOutlet UITextField *chatMessageField;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *messages;

@end

@implementation ChatViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.messages = [[NSMutableArray alloc]init];
    self.tableView.dataSource = self;
    
    [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(onTimerRefresh) userInfo:nil repeats:true];
    // Do any additional setup after loading the view.
//    UIRefreshControl *refreshControl =[[UIRefreshControl alloc]init];
//    [refreshControl addTarget:self action:@selector(onTimerRefresh:) forControlEvents:UIControlEventValueChanged];
  
}

- (void)onTimerRefresh {

    [self retrieveAllMessages];
    
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (IBAction)didTapSend:(id)sender {
    [self sendMessageWithText];

}
-(void) sendMessageWithText {
    //createing new message and saving it to Parse
    PFObject *chatMessage = [PFObject objectWithClassName:@"Message_FBU2021"];
    //storing text of text field in key called "text"
    chatMessage[@"text"] = self.chatMessageField.text;
    // call saveInBackground and print when the message successfully saves or any errors
    [chatMessage saveInBackgroundWithBlock:^(BOOL succeeded, NSError * error) {
        if (succeeded) {
            NSLog(@"The message was saved!");
            self.chatMessageField.text = nil;
            [self.messages addObject:chatMessage[@"text"]];
            [self.tableView reloadData];
        } else {
            NSLog(@"Problem saving message: %@", error.localizedDescription);
        }
    }];
    
}

-(void)retrieveAllMessages {
    // TODO: retriving data from Parse
    PFQuery *query = [PFQuery queryWithClassName:@"Message_FBU2021"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *posts, NSError *error) {
        if (posts != nil) {
            // do something with the array of object returned by the call
            NSMutableArray *textOfPosts = [[NSMutableArray alloc]init];
            for (PFObject *post in posts) {
                [textOfPosts addObject: post[@"text"]];
            }
            if (![self.messages isEqual:textOfPosts]) {
                self.messages = textOfPosts;
                [self.tableView reloadData];
            }
        } else {
            NSLog(@"%@", error.localizedDescription);
        }
    }];
   
}

- (UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {

    
    ChatCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"ChatCell"forIndexPath:indexPath];
    cell.chatMessage.text = self.messages[indexPath.row];
    
    return cell;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.messages.count;
}



@end
