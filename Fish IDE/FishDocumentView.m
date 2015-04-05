//
//  FishDocumentView.m
//  Fish IDE
//
//  Created by Jussi Enroos on 13.3.2015.
//  Copyright (c) 2015 Jussi Enroos. All rights reserved.
//

#import "FishDocumentView.h"
#import "FishProgram.h"

@implementation FishDocumentView
{
    NSPoint _textOrigin;
    NSSize _fontSize;
    
    FPoint _ip;
    FSize _negativeAreaSize;
    
    NSString *_fontName;
    NSFont *_codeFont;
    
    /*
     *  Text strings
     */
    
    NSString *_textBR;
    NSString *_textBL;
    NSString *_textTR;
    NSString *_textTL;
    
    /*
     *  Color settings
     */
    
    NSColor *_gridColor;
    NSColor *_axisColor;
    NSColor *_fontColor;
    NSColor *_cursorColor;
}

- (void)awakeFromNib
{
    // Initialization
    [self setFontName:nil];
    [self setFontSize:12.f];
    
    _negativeAreaSize = fsz(3,3);
    _textOrigin = NSMakePoint(_negativeAreaSize.width * _fontSize.width,
                              self.frame.size.height - _negativeAreaSize.height * _fontSize.height);

    // Default color values
    _gridColor = [NSColor colorWithDeviceRed:0.2f green:0.2f blue:0.2f alpha:0.1f];
    _axisColor = [NSColor colorWithDeviceRed:0.2f green:0.2f blue:0.2f alpha:0.3f];
    _cursorColor = [NSColor colorWithDeviceRed:0.f green:0.9f blue:0.1f alpha:1.f];
    _fontColor = [NSColor blackColor];
    
    // Default text
    _textBR =
    @"'!dlroW olleH'>l0)?vov \n"
    @"              ^      < \n"
    @"                   ;   \n";
    
    _ip = fpp(0, 0);
}

- (void) setFontName:(NSString*) fontName
{
    // Set font, find from a list
    NSMutableArray *fontList = [@[@"Menlo Regular", @"Consolas", @"Courier"] mutableCopy];
    if (fontName != nil) {
        [fontList insertObject:fontName atIndex:0];
    }
    
    for (NSString *string in fontList) {
        _codeFont = [NSFont fontWithName:string size:1];
        if (_codeFont == nil) {
            continue;
        }
        _fontName = string;
        break;
    }
}

- (void) setFontSize:(CGFloat) size
{
    _fontSize.height = size;
    _codeFont = [NSFont fontWithName:_fontName size:_fontSize.height];
    
    // Create a string with the font to get character width
    NSDictionary *fontAttributes = @{NSFontAttributeName: _codeFont};
    NSAttributedString *letter = [[NSAttributedString alloc] initWithString:@"a" attributes:fontAttributes];
    
    _fontSize.width = [letter size].width;
    _fontSize.height = [letter size].height;
}


- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    NSDictionary *attributes = @{NSFontAttributeName: _codeFont,
                                 NSForegroundColorAttributeName: _fontColor};
    
    NSAttributedString * currentText=[[NSAttributedString alloc] initWithString:_textBR attributes: attributes];
    
    /*
     *  Draw origin (and possibly a grid?)
     */
    
    // Horizontal line
    NSBezierPath *gridPath = [NSBezierPath bezierPath];
    if (dirtyRect.origin.y < _textOrigin.y &&
        dirtyRect.origin.y + dirtyRect.size.height > _textOrigin.y) {
        [gridPath moveToPoint:NSMakePoint(floorf(dirtyRect.origin.x) - 0.5f, floorf(_textOrigin.y) - 0.5f)];
        [gridPath lineToPoint:NSMakePoint(floorf(dirtyRect.origin.x + dirtyRect.size.width) - 0.5f, floorf(_textOrigin.y) - 0.5f)];
    }
    // Vertical line
    if (dirtyRect.origin.x < _textOrigin.x &&
        dirtyRect.origin.x + dirtyRect.size.width > _textOrigin.x) {
        [gridPath moveToPoint:NSMakePoint(floorf(_textOrigin.x) - 0.5f, floorf(dirtyRect.origin.y) - 0.5f)];
        [gridPath lineToPoint:NSMakePoint(floorf(_textOrigin.x) - 0.5f, floorf(dirtyRect.origin.y + dirtyRect.size.height) - 0.5f)];
    }
    
    NSLog(@"Rect size: %.2f, %.2f origin: %.2f, %.2f", dirtyRect.size.width, dirtyRect.size.height, dirtyRect.origin.x, dirtyRect.origin.y);
    
    [_axisColor set];
    [gridPath setLineWidth:0.0];
    [gridPath stroke];
    
    /*
     *  Draw cursor
     */
    
    [_cursorColor set];
    NSRectFill(NSMakeRect(_textOrigin.x + _ip.x * _fontSize.width, _textOrigin.y - (_ip.y + 1) * _fontSize.height, _fontSize.width, _fontSize.height));
    
    /*
     *  Draw actual text
     */
    
    NSSize attrSize = [currentText size];
    
    [currentText drawAtPoint:NSMakePoint(_textOrigin.x, _textOrigin.y - attrSize.height)];
}

- (void)playSelected
{
    NSLog(@"PLAY!");
}

- (void)stopSelected
{
    NSLog(@"STOP!");
}

#pragma mark - Fish Interpreter Delegate

- (void)ipMovedTo:(FPoint)point
{
    _ip = point;
    // TODO: force redraw
    [self setNeedsDisplay:YES];
}

@end
