#import <Cocoa/Cocoa.h>
#import <objc/runtime.h>

#import "XCFixin.h"

static IMP gOriginalInitWithDuration = nil;
static IMP gOriginalSetDuration = nil;
static IMP gOriginalSetAlphaValue = nil;
static IMP gOriginalShowWindowForTextFrameExplicitAnimation = nil;

@interface XCFixin_DisableAnimations : NSObject
@end

@implementation XCFixin_DisableAnimations

static void overrideInitWithDuration(id self, SEL _cmd, NSTimeInterval arg1, NSAnimationCurve arg2)
{
    /* -[NSAnimation initWithDuration:(NSTimeInterval)duration animationCurve:(NSAnimationCurve)animationCurve] */
    ((void (*)(id, SEL, NSTimeInterval, NSAnimationCurve))gOriginalInitWithDuration)(self, _cmd, 0.0, arg2);
}

static void overrideSetDuration(id self, SEL _cmd, NSTimeInterval arg1)
{
    /* -[NSAnimation setDuration:(NSTimeInterval)duration] */
    ((void (*)(id, SEL, NSTimeInterval))gOriginalSetDuration)(self, _cmd, 0.0);
}

static void overrideShowWindowForTextFrameExplicitAnimation(id self, SEL _cmd, NSRect arg1, BOOL arg2)
{
    /* -[DVTTextCompletionListWindowController showWindowForTextFrame:(NSRect)textFrame explicitAnimation:(BOOL)usesExplicitAnimation] */
    ((void (*)(id, SEL, NSRect, BOOL))gOriginalShowWindowForTextFrameExplicitAnimation)(self, _cmd, arg1, NO);
}

static void overrideSetAlphaValue(id self, SEL _cmd, CGFloat windowAlpha)
{
    /* -[DVTTextCompletionWindow setAlphaValue:(CGFloat)windowAlpha] */
	if(windowAlpha == 0.0) {
		((void (*)(id, SEL, NSTimeInterval))gOriginalSetAlphaValue)(self, _cmd, 0.0);
	} else {
		((void (*)(id, SEL, NSTimeInterval))gOriginalSetAlphaValue)(self, _cmd, 1.0);
	}
}

+ (void)pluginDidLoad: (NSBundle *)plugin
{
    XCFixinPreflight();
    
    /* Override -[NSAnimation initWithDuration:(NSTimeInterval)duration animationCurve:(NSAnimationCurve)animationCurve] */
    gOriginalInitWithDuration = XCFixinOverrideMethodString(@"NSAnimation", @selector(initWithDuration: animationCurve:), (IMP)&overrideInitWithDuration);
        XCFixinAssertOrPerform(gOriginalInitWithDuration, goto failed);
    
    /* Override -[NSAnimation setDuration:(NSTimeInterval)duration] */
    gOriginalSetDuration = XCFixinOverrideMethodString(@"NSAnimation", @selector(setDuration:), (IMP)&overrideSetDuration);
        XCFixinAssertOrPerform(gOriginalSetDuration, goto failed);

    /* Override -[DVTTextCompletionWindow setAlphaValue:(CGFloat)windowAlpha] */
    gOriginalSetAlphaValue = XCFixinOverrideMethodString(@"DVTTextCompletionWindow", @selector(setAlphaValue:), (IMP)&overrideSetAlphaValue);
        XCFixinAssertOrPerform(gOriginalSetAlphaValue, goto failed);

    /* Override -[DVTTextCompletionListWindowController showWindowForTextFrame:(NSRect)textFrame explicitAnimation:(BOOL)usesExplicitAnimation] */
    gOriginalShowWindowForTextFrameExplicitAnimation = XCFixinOverrideMethodString(@"DVTTextCompletionListWindowController", @selector(showWindowForTextFrame:explicitAnimation:), (IMP)&overrideShowWindowForTextFrameExplicitAnimation);
        XCFixinAssertOrPerform(gOriginalShowWindowForTextFrameExplicitAnimation, goto failed);
    
    XCFixinPostflight();
}

@end