#ifndef PS_PREFS
#define PS_PREFS

#import "PSHeader/Misc.h"

#define toPrefPath() realPrefPath(tweakIdentifier)
#define toPostNotification() [NSString stringWithFormat:@"%@/ReloadPrefs", tweakIdentifier]

#define DoPostNotification() CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), (CFStringRef)toPostNotification(), NULL, NULL, YES)

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

#endif