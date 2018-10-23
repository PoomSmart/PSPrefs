#import <Foundation/Foundation.h>
#import <Preferences/PSSpecifier.h>
#import <Preferences/PSViewController.h>
#import "PSHeader/Misc.h"

#define toPrefPath() realPrefPath(tweakIdentifier)
#define toPostNotification() [NSString stringWithFormat:@"%@/ReloadPrefs", tweakIdentifier]

#define DoPostNotification() CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), (CFStringRef)toPostNotification(), NULL, NULL, YES)

#define GetPrefs() NSDictionary *PSSettings = [NSDictionary dictionaryWithContentsOfFile:toPrefPath()];
#define DeclarePrefs() NSDictionary *_PSSettings() { GetPrefs() return PSSettings; }
#define DeclareSaver() \
    void setValueForKey(id value, NSString *key, BOOL post) { \
        NSMutableDictionary *dictionary = [NSMutableDictionary dictionary]; \
        [dictionary addEntriesFromDictionary:_PSSettings()]; \
        [dictionary setObject:value forKey:key]; \
        [dictionary writeToFile:toPrefPath() atomically:YES]; \
        if (post) \
            DoPostNotification(); \
    }
#define setObjectForKey(val, key) setValueForKey(val, key, NO)
#define setBoolForKey(val, key) setValueForKey(@(val), key, NO)
#define setIntForKey(val, key) setValueForKey(@(val), key, NO)
#define setFloatForKey(val, key) setValueForKey(@(val), key, NO)
#define setDoubleForKey(val, key) setValueForKey(@(val), key, NO)
#define setCGFloatForKey(val, key) setFloatForKey(val, key)

#define DeclareGetter() \
    id valueForKey(NSString *key, id defaultVal) { \
        id val = _PSSettings()[key]; \
        return val ? val : defaultVal; \
    }
#define objectForKey(key, defaultVal) valueForKey(key, defaultVal)
#define boolForKey(key, defaultVal) [valueForKey(key, @(defaultVal)) boolValue]
#define intForKey(key, defaultVal) [valueForKey(key, @(defaultVal)) intValue]
#define floatForKey(key, defaultVal) [valueForKey(key, @(defaultVal)) floatValue]
#if CGFLOAT_IS_DOUBLE
#define cgfloatForKey(key, defaultVal) [valueForKey(key, @(defaultVal)) doubleValue]
#else
#define cgfloatForKey(key, defaultVal) [valueForKey(key, @(defaultVal)) floatValue]
#endif

#define DeclarePrefsTools() \
    DeclarePrefs() \
    DeclareGetter() \
    DeclareSaver()

#define GetVal(TYPE, val, key, defaultVal) val = [PSSettings objectForKey:key] ? [[PSSettings objectForKey:key] TYPE ## Value] : defaultVal;
#define GetGeneric(val, key, defaultVal) val = [PSSettings objectForKey:key] ? [PSSettings objectForKey:key] : (defaultVal);
#define GetObject(val, key, defaultVal) GetGeneric(val, key, (defaultVal))
#define GetObject2(val, defaultVal) GetObject(val, val ## Key, (defaultVal))
#define GetBool(val, key, defaultVal) GetVal(bool, val, key, defaultVal)
#define GetBool2(val, defaultVal) GetBool(val, val ## Key, defaultVal)
#define GetFloat(val, key, defaultVal) GetVal(float, val, key, defaultVal)
#define GetFloat2(val, defaultVal) GetFloat(val, val ## Key, defaultVal)
#define GetDouble(val, key, defaultVal) GetVal(double, val, key, defaultVal)
#define GetDouble2(val, defaultVal) GetDouble(val, val ## Key, defaultVal)
#if CGFLOAT_IS_DOUBLE
#define GetCGFloat(val, key, defaultVal) GetDouble(val, key, defaultVal)
#define GetCGFloat2(val, defaultVal) GetDouble2(val, defaultVal)
#else
#define GetCGFloat(val, key, defaultVal) GetFloat(val, key, defaultVal)
#define GetCGFloat2(val, defaultVal) GetFloat2(val, defaultVal)
#endif
#define GetInt(val, key, defaultVal) GetVal(int, val, key, defaultVal)
#define GetInt2(val, defaultVal) GetInt(val, val ## Key, defaultVal)

#define HaveCallback() static void callback()
#define HaveObserver() CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)callback, (CFStringRef)toPostNotification(), NULL, CFNotificationSuspensionBehaviorCoalesce)

#define _HavePrefs(ACTION) \
    - (id)readPreferenceValue:(PSSpecifier *)specifier { \
        NSDictionary *settings = [NSDictionary dictionaryWithContentsOfFile:toPrefPath()]; \
        id key = [settings objectForKey:[specifier.properties objectForKey:@"key"]]; \
        if (!key) \
            return [specifier.properties objectForKey:@"default"]; \
        return key; \
    } \
    - (void)setPreferenceValue:(id)value specifier:(PSSpecifier *)specifier { \
        NSMutableDictionary *dictionary = [NSMutableDictionary dictionary]; \
        NSString *prefPath = toPrefPath(); \
        [dictionary addEntriesFromDictionary:[NSDictionary dictionaryWithContentsOfFile:prefPath]]; \
        [dictionary setObject:value forKey:[specifier.properties objectForKey:@"key"]]; \
        [dictionary writeToFile:prefPath atomically:YES]; \
        CFStringRef post = (CFStringRef)[specifier.properties objectForKey:@"PostNotification"]; \
        if (post) \
            CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), post, NULL, NULL, YES); \
        ACTION \
    }

#define HavePrefs() _HavePrefs(; )

#define defaultTweakFontSize 50.0
#define defaultDesFontSize 14.0

#define HaveBanner(tweakName, tweakColor, tweakFontSize, description, desColor, desFontSize) \
    - (void)loadView \
    { \
        [super loadView]; \
        UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 110)]; \
        UILabel *tweakLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 16, 320, tweakFontSize)]; \
        tweakLabel.text = tweakName; \
        tweakLabel.textColor = tweakColor; \
        tweakLabel.backgroundColor = UIColor.clearColor; \
        tweakLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:tweakFontSize]; \
        tweakLabel.textAlignment = 1; \
        tweakLabel.autoresizingMask = 0x12; \
        [headerView addSubview:tweakLabel]; \
        [tweakLabel release]; \
        UILabel *des = [[UILabel alloc] initWithFrame:CGRectMake(0, 75, 320, 20)]; \
        des.text = description; \
        if (desColor) \
            des.textColor = desColor; \
        des.alpha = 0.8; \
        des.font = [UIFont systemFontOfSize:desFontSize]; \
        des.backgroundColor = UIColor.clearColor; \
        des.textAlignment = 1; \
        des.autoresizingMask = 0xa; \
        [headerView addSubview:des]; \
        [des release]; \
        self.table.tableHeaderView = headerView; \
        [headerView release]; \
    }

#define HaveBanner2(tweakName, tweakColor, description, desColor) HaveBanner(tweakName, tweakColor, defaultTweakFontSize, description, desColor, defaultDesFontSize)
