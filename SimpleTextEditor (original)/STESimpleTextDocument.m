//
//  STESimpleTextDocument.m
//  SimpleTextEditor
//
//  Created by Jason Tsai on 7/30/14.
//  Copyright (c) 2014 nick. All rights reserved.
//

#import "STESimpleTextDocument.h"

@implementation STESimpleTextDocument
@synthesize documentText = _documentText;
@synthesize delegate = _delegate;
@synthesize new;

- (void)setDocumentText:(NSString *)newText {
    NSString* oldText = _documentText;
    _documentText = [newText copy];


    [self.undoManager setActionName:@"Text Change"];
    [self.undoManager registerUndoWithTarget:self
                                    selector:@selector(setDocumentText:)
                                      object:oldText];




    }

- (id)contentsForType:(NSString *)typeName error:(NSError **)outError {
    if (!self.documentText)
        self.documentText = @"";
    NSData *docData = [self.documentText
                       dataUsingEncoding:NSUTF8StringEncoding];
    return docData;
}

- (BOOL)loadFromContents:(id)contents
                  ofType:(NSString *)typeName
                   error:(NSError **)outError {
    if ([contents length] > 0)
    {
        self.documentText = [[NSString alloc]
                             initWithData:contents
                             encoding:NSUTF8StringEncoding];
    }
        else
        
        self.documentText = @"";
    if (self.delegate && [self.delegate respondsToSelector:
                          @selector(documentContentsDidChange:)])
        [self.delegate documentContentsDidChange:self];
    
            return YES;
}
@end
