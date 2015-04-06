//
//  FishDocumentView.m
//  Fish IDE
//
//  Created by Jussi Enroos on 13.3.2015.
//  Copyright (c) 2015 Jussi Enroos. All rights reserved.
//

#import "FishDocumentView.h"

#import "FishProgram.h"
#import "FishInterpreter.h"
#import "FishInstructionSetManager.h"

typedef enum {
    is_none,
    is_running,
    is_requiresInput,
    is_breakpoint,
    is_finished,
    is_error,
} InterpreterState;

@implementation FishDocumentView
{
    NSPoint _textOrigin;
    NSSize _fontSize;
    
    FPoint _ip;
    FPoint _cursor;
    FSize _negativeAreaSize;
    
    NSString *_fontName;
    NSFont *_codeFont;
    
    /*
     *  Text strings
     */
    
    NSString *_textBR;
    NSMutableString *_textBL;
    NSMutableString *_textTR;
    NSMutableString *_textTL;
    
    NSMutableString *_outputString;
    
    NSMutableArray *_textArray;
    
    /*
     *  Color settings
     */
    
    NSColor *_gridColor;
    NSColor *_axisColor;
    NSColor *_fontColor;
    NSColor *_cursorColor;
    NSColor *_stopColor;
    NSColor *_ipColor;
    
    /*
     *  Interpreting the source
     */
    
    FishInterpreter *_interpreter;
    FishInstructionSetManager *_isManager;
    FishProgram *_program;
    
    InterpreterState _iState;
    
    NSTimer *_interpreterTimer;
    NSTimeInterval _interpreterTimeInterval; // double
    
    /*
     *  Input
     */
    
    NSMutableSet *_acceptableCharacterInputs;
}

- (BOOL)acceptsFirstResponder
{
    return YES;
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
    _gridColor      = [NSColor colorWithDeviceRed:0.2f green:0.2f blue:0.2f alpha:0.1f];
    _axisColor      = [NSColor colorWithDeviceRed:0.2f green:0.2f blue:0.2f alpha:0.3f];
    _ipColor        = [NSColor colorWithDeviceRed:0.f  green:0.9f blue:0.1f alpha:1.f];
    _stopColor      = [NSColor colorWithDeviceRed:0.9f green:0.1f blue:0.1f alpha:1.f];
    _cursorColor    = [NSColor colorWithDeviceRed:0.1f green:0.0f blue:0.9f alpha:1.f];
    _fontColor      = [NSColor blackColor];
    
    _textArray      = [[NSMutableArray alloc] init];
    
    // Default text
    _textBR =
    @"'!dlroW olleH'>l0)?vov \n"
    @"              ^      < \n"
    @"                   ;   \n";
    
    [self resetWithText:_textBR];
    
    _ip = fpp(0, 0);
    
    _isManager = [[FishInstructionSetManager alloc] init];
    _interpreter = [[FishInterpreter alloc] initWithISManager:_isManager];
    
    _program = [FishProgram programFromFileContents:_textBR];
    [_interpreter initializeProgram:_program];
    _interpreter.delegate = self;
    
    _iState = is_none;
    
    _interpreterTimer = nil;
    _interpreterTimeInterval = 0.05;
    
    
    // Status bar
    [self setStatusString:@"Ready"];
    
}

- (void) setStatusString:(NSString*) string
{
    _statusField.stringValue = string;
    _statusField.needsDisplay = YES;
}

- (void) resetWithText:(NSString*) text
{
    [_textArray removeAllObjects];
    
    NSArray *componentArray = [text componentsSeparatedByString:@"\n"];
    for (NSString *string in componentArray) {
        [_textArray addObject:[string mutableCopy]];
    }
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
    
    _fontSize.width  = [letter size].width;
    _fontSize.height = [letter size].height;
}


- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    NSDictionary *attributes = @{NSFontAttributeName: _codeFont,
                                 NSForegroundColorAttributeName: _fontColor};
    
    //NSAttributedString * currentText=[[NSAttributedString alloc] initWithString:_textBR attributes: attributes];
    
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
    
    //NSLog(@"Rect size: %.2f, %.2f origin: %.2f, %.2f", dirtyRect.size.width, dirtyRect.size.height, dirtyRect.origin.x, dirtyRect.origin.y);
    
    [_axisColor set];
    [gridPath setLineWidth:0.0];
    [gridPath stroke];
    
    /*
     *  Draw cursor
     */
    
    if (_iState == is_none) {
        // Normal cursor
        [_cursorColor set];
        NSRectFill(NSMakeRect(_textOrigin.x + _cursor.x * _fontSize.width, _textOrigin.y - (_cursor.y + 1) * _fontSize.height, _fontSize.width, _fontSize.height));
    }
    else if (_iState == is_requiresInput || _iState == is_running || _iState == is_finished || _iState == is_breakpoint) {
        [_ipColor set];
        NSRectFill(NSMakeRect(_textOrigin.x + _ip.x * _fontSize.width, _textOrigin.y - (_ip.y + 1) * _fontSize.height, _fontSize.width, _fontSize.height));
    }
    else if (_iState == is_error) {
        [_stopColor set];
        NSRectFill(NSMakeRect(_textOrigin.x + _ip.x * _fontSize.width, _textOrigin.y - (_ip.y + 1) * _fontSize.height, _fontSize.width, _fontSize.height));
    }
    
    /*
     *  Draw actual text
     */
    
    
    int line = 1;
    for (NSMutableString *string in _textArray) {
        [string drawAtPoint:NSMakePoint(_textOrigin.x, _textOrigin.y /*- attrSize.height*/ - line * _fontSize.height) withAttributes:attributes];
        line++;
    }
    
    
    //NSSize attrSize = [currentText size];
    //[currentText drawAtPoint:NSMakePoint(_textOrigin.x, _textOrigin.y - attrSize.height)];
}

- (void)playSelected
{
    // Start the interpreter
    if (_iState == is_running || _iState == is_requiresInput) {
        NSLog(@"Program running");
        return;
    }
    
    [self setStatusString:@"Running"];
    
    _iState = is_running;
    
    // Create program
    //_program = [FishProgram programFromFileContents:_textBR];
    _program = [FishProgram programFromLines:_textArray];
    [_interpreter initializeProgram:_program];
    
    // Start playing
    [self performSelectorOnMainThread:@selector(startTimer) withObject:nil waitUntilDone:NO];
    
    // Enable stop button
    _stopButton.enabled = YES;
}

- (void) startTimer
{
    _interpreterTimer = [NSTimer timerWithTimeInterval:_interpreterTimeInterval target:self selector:@selector(interpreterUpdate:) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:_interpreterTimer forMode:NSRunLoopCommonModes];
}

- (void)stopSelected
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [_interpreterTimer invalidate];
    });
    
    _stopButton.enabled = NO;
    
    _iState = is_none;
    
    [self setStatusString:@"Stopped"];
}

- (void) interpreterUpdate:(NSTimer*) sender
{
    // Counter here?
    FishInterpreterError error = [_interpreter executeStep];
    
    if (error != fie_none) {
        _stopButton.enabled = NO;
        
        if (error != fie_finished) {
            NSLog(@"Interpreter error: %@", [FishInterpreter errorString:error]);
            [self setStatusString:[NSString stringWithFormat:@"Error: %@", [FishInterpreter errorString:error]]];
            _iState = is_error;
        }
        else {
            [self setStatusString:@"Finished"];
            _iState = is_finished;
        }

        // Stop interpeter
        dispatch_async(dispatch_get_main_queue(), ^{
            [_interpreterTimer invalidate];
        });
    }
}

#pragma mark - Keyboard control

- (void)mouseDown:(NSEvent *)theEvent
{
    NSLog(@"Mouse clicked");
    
    if (_iState == is_error || _iState == is_finished) {
        // Enable editor mode
        _iState = is_none;
        [self setNeedsDisplay:YES];
    }
}

- (void)doCommandBySelector:(SEL)aSelector
{
    NSLog(@"Command %@", NSStringFromSelector(aSelector));
    
    if ([self respondsToSelector:aSelector]) {
        [self performSelector:aSelector withObject:self];
    }
}

- (void)keyDown:(NSEvent *)theEvent
{
    [self interpretKeyEvents:@[theEvent]];
}

- (void)keyUp:(NSEvent *)theEvent
{
    
}

- (void)flagsChanged:(NSEvent *)theEvent
{
    
}

#pragma mark - Keyboard events

- (void)insertText:(NSString*)insertString
{
    if (!!! [self editorMode]) {
        return;
    }
    
    //NSLog(@"Key down");
    NSLog(@"Key: %@ %d", insertString, [insertString characterAtIndex:0]);
    
    // Acceptable inserts
    
    // Get the correct line
    NSMutableString *line = [_textArray objectAtIndex:_cursor.y];
    [line insertString:insertString atIndex:_cursor.x];
    
    _cursor.x++;
    
    // Redraw
    [self setNeedsDisplay:YES];
}

- (void)insertNewline:(id)sender
{
    if (!!! [self editorMode]) {
        return;
    }
    
    // Get the correct line
    NSMutableString *line = [_textArray objectAtIndex:_cursor.y];
    NSMutableString *newLine = [NSMutableString stringWithString:[line substringFromIndex:_cursor.x]];
    [line deleteCharactersInRange: NSMakeRange(_cursor.x, line.length - _cursor.x)];

    [_textArray insertObject:newLine atIndex:_cursor.y+1];
    
    _cursor.x = 0;
    _cursor.y ++;
    
    // Redraw
    [self setNeedsDisplay:YES];
}

- (void)moveUp:(id)sender
{
    if (!!! [self editorMode]) {
        return;
    }
    
    if (_cursor.y > 0) {
        _cursor.y --;
    }
    
    // Redraw
    [self setNeedsDisplay:YES];
}

- (void)moveDown:(id)sender
{
    if (!!! [self editorMode]) {
        return;
    }
    
    _cursor.y ++;
    
    // Redraw
    [self setNeedsDisplay:YES];
}

- (void)moveLeft:(id)sender
{
    if (!!! [self editorMode]) {
        return;
    }
    
    if (_cursor.x > 0) {
        _cursor.x --;
    }
    
    // Redraw
    [self setNeedsDisplay:YES];
}

- (void)moveRight:(id)sender
{
    if (!!! [self editorMode]) {
        return;
    }
    
    _cursor.x ++;
    
    // Redraw
    [self setNeedsDisplay:YES];
}

- (void)deleteBackward:(id)sender
{
    if (!!! [self editorMode]) {
        return;
    }
    
    if (_cursor.x == 0) {
        if (_cursor.y == 0) {
            return;
        }
        // Move the entire line after the previous one
        
        NSMutableString *line = [_textArray objectAtIndex:_cursor.y];
        NSMutableString *previousLine = [_textArray objectAtIndex:_cursor.y-1];
        
        _cursor.x = (int)previousLine.length;
        
        [previousLine appendString:line];
        
        [_textArray removeObjectAtIndex:_cursor.y];
        _cursor.y --;
        
        // Redraw
        [self setNeedsDisplay:YES];
        return;
    }
    
    // Get the correct line
    NSMutableString *line = [_textArray objectAtIndex:_cursor.y];
    [line deleteCharactersInRange: NSMakeRange(_cursor.x-1, 1)];
    
    _cursor.x --;
    
    // Redraw
    [self setNeedsDisplay:YES];
}

- (void)deleteForward:(id)sender
{
    if (!!! [self editorMode]) {
        return;
    }
    
    // Get the correct line
    NSMutableString *line = [_textArray objectAtIndex:_cursor.y];
    
    if (_cursor.x >= line.length) {
        if (_cursor.y >= _textArray.count - 1) {
            return;
        }
        
        // Join the next line
        NSMutableString *line = [_textArray objectAtIndex:_cursor.y];
        NSMutableString *nextLine = [_textArray objectAtIndex:_cursor.y+1];
        
        [line appendString:nextLine];
        
        [_textArray removeObjectAtIndex:_cursor.y+1];
        
        // Redraw
        [self setNeedsDisplay:YES];
        return;
    }
    
    [line deleteCharactersInRange: NSMakeRange(_cursor.x, 1)];
    
    // Redraw
    [self setNeedsDisplay:YES];
}

- (BOOL) editorMode
{
    if (_iState == is_error || _iState == is_finished) {
        // Enable editor mode
        _iState = is_none;
    }
    
    if (_iState != is_none) {
        NSLog(@"Not in editor mode");
        return NO;
    }
    
    return YES;
}


#pragma mark - Fish Interpreter Delegate

- (void)ipMovedTo:(FPoint)point
{
    _ip = point;
    //NSLog(@"IP %d,%d", _ip.x, _ip.y);
    
    // TODO: force redraw
    [self setNeedsDisplay:YES];
}

- (void)requestInput
{
    NSLog(@"Program requires intput");
    _iState = is_requiresInput;
}

- (void)output:(NSString *)output
{
    [_outputString appendString:output];
    printf("%s", [output UTF8String]);
}

@end
