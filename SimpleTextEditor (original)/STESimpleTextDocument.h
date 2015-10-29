//
//  STESimpleTextDocument.h
//  SimpleTextEditor
//
//  Created by Jason Tsai on 7/30/14.
//  Copyright (c) 2014 nick. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol STESimpleTextDocumentDelegate;

@interface STESimpleTextDocument : UIDocument

@property (copy, nonatomic) NSString* documentText;
@property (weak, nonatomic) id<STESimpleTextDocumentDelegate> delegate;
@property BOOL new;
@end


@protocol STESimpleTextDocumentDelegate <NSObject>
@optional
- (void)documentContentsDidChange:(STESimpleTextDocument*)document;
@end
