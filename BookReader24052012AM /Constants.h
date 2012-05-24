//
//  DataConstants.h
//  ChartPad
//
//  Created by administrator on 9/21/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#define REAL_TIME_HOST @"qs02.aws.ddfplus.com" //@"qs01.ddfplus.com"
#define REAL_TIME_HISTORICAL_HOST @"http://ds01.ddfplus.com/historical/"
#define keySymbolList @"keySymbolList"

#define YAHOO_SERVICE @"YAHOO"
#define DDF_SERVICE @"DDF"

#define LOW_INTERNET_SIGNAL @"Low internet signal. Would you like to reconnect?"

typedef enum
{
    HotKeyIncreaseTemplate = 1,
    HotKeyDecreaseTemplate
}HotKeyType;

typedef enum
{
    SettingWindowAndrewPitchfort = 0,
    SettingWindowFibRetracement,
    SettingWindowFibExtension,
    SettingWindowSegment,
    SettingWindowRay,
    SettingWindowHorizontal,
    SettingWindowVertical,
    SettingWindowExtended
}SettingWindowType;

@interface Constants : NSObject {

}
// those constant to save some data in NSUserDefaults, to let app load from NSUserDefaults to display on the screen when user reopen the app
extern NSString * const kSocketErrorNotification;
extern NSString * const kSocketDisconnectNotification;
extern NSString * const kSocketReturnNotification;
extern NSString * const kTimestampReturnNotification;

extern NSString * const kLoggingNotification;
extern NSString * const kInvalidLoginNotification;
extern NSString * const kSuccessLoginNotification;
extern NSString * const kDualLoginNotification;
extern NSString * const kUsernameExpirationNotification;
extern NSString * const kChangeViewControllerNotification;
extern NSString * const kStopStreamOutsideOfSessionNotification;

extern NSString * const kQuoteScreenLoginSuccessfulNotification;

extern NSString * const kOperationFilterContentSearchTextDoneNotification;
extern NSString * const kShouldMergeQuoteEntriesFromiCloudNotification;
extern NSString * const kShouldReloadDefaultChartSettingsNotification;

extern NSString * const kInitialQuoteEntries;
extern NSString * const kCurrentTimeZoneName;
extern NSString * const kCurrentTimeZone;
extern NSString * const kCurrentSymbol;
extern NSString * const kCurrentLocation;
extern NSString * const kCurrentBarWidth;
extern NSString * const kCurrentBarSpacing;
extern NSString * const kOpenCurrentWidth;
extern NSString * const kOpenCurrentThickness;
extern NSString * const kCloseCurrentWidth;
extern NSString * const kCloseCurrentThickness;

extern NSString * const kChartObjects;
extern NSString * const kChartObjectsUsingNSDictionary;
extern NSString * const kTimeScaleList;
extern NSString * const kCurrentTimeScale;

extern NSString * const kUserUtilityUsername;
extern NSString * const kUserUtilityPassword;
extern NSString * const kUsernameExpiredDate;
extern NSString * const kResetUsernameAndPassword;
extern NSString * const kUserSettingsDefaultStreamingHost;
extern NSString * const kUserSettingsDefaultPrimaryHistoricalv2Host;
extern NSString * const kUserSettingsDefaultSecondaryHistoricalv2Host;

//custom theme
extern NSString * const kCustomNavyTheme;
extern NSString * const kCustomSlateGradientTheme;

// Format dictionary when receiving data from provider
extern const NSString * kSymbol;
extern const NSString * kExtendedStartDate;
extern const NSString * kStartDate;
extern const NSString * kEndDate;
extern const NSString * kOverallHigh;
extern const NSString * kOverallLow;
extern const NSString * kOverallVolumeHigh;
extern const NSString * kOverallVolumeLow;
extern const NSString * kFinancialData;
extern const NSString * kExtendedData;
// Dictionary for building symbols list
extern const NSString * kSymbolKey;
extern const NSString * kCompanyNameKey;
extern const NSString * kLastTradeKey;
extern const NSString * kLastChangeKey;

//identifier for chart objects
extern const NSString * kMovingAverageIdentifier;
extern const NSString * kBollingerBandsId;
extern const NSString * kDonchianBands;
extern const NSString * kKeltnerChannelsIdentifier;
extern const NSString * kParabolicSAR;
extern const NSString * kMovingAverageEnvelopes;
extern const NSString * kPivotPoints;
extern const NSString * kVolumeByPriceId;

extern const NSString * kVolumeIdentifier;
extern const NSString * kMACDId;
extern const NSString * kStochasticsFastIdentifier; 
extern const NSString * kStochasticsSlowIdentifier;
extern const NSString * kAverageDirectionalIndex;
extern const NSString * kRelativeStrengthIndex;
extern const NSString * kCommodityChannelIndex;
extern const NSString * kAverageTrueRange;
extern const NSString * kOnBalanceVolume;
extern const NSString * kWilliamsPercentRange;
extern const NSString * kRateOfChange;
extern const NSString * kMomentum;
extern const NSString * kChaikinMoneyFlow;
extern const NSString * kComparedSecurity;

extern const NSString * kAccumulationDistributionId;
extern const NSString * kChaikinOscillatorId;
extern const NSString * kAverageDirectionalRatingId;
extern const NSString * kAbsolutePriceOscillatorId;
extern const NSString * kAroonId;
extern const NSString * kAroonOscillatorId;
extern const NSString * kBalanceOfPowerId;
extern const NSString * kChaideMomentumOscillatorId;
extern const NSString * kDirectionalMovementIndexId;
extern const NSString * kMoneyFlowIndexId;
extern const NSString * kPercentagePriceOscillatorId;
extern const NSString * kStandardDeviationId;
extern const NSString * kStochasticRelativeStrengthIndexId;
extern const NSString * kSummationId;
extern const NSString * kTimeSeriesForecastId;
extern const NSString * kROCofTEMAId;
extern const NSString * kVolumePlotSpaceId;
extern const NSString * kMACDPlotSpaceId;
extern const NSString * kStochasticsFastPlotSpaceId;
extern const NSString * kStochasticsSlowPlotSpaceId;
extern const NSString * kAverageDirectionalIndexPlotSpaceId;
extern const NSString * kRelativeStrengthIndexPlotSpaceId;
extern const NSString * kCommodityChannelIndexPlotSpaceId;
extern const NSString * kAverageTrueRangePlotSpaceId;
extern const NSString * kOnBalanceVolumePlotSpaceId;
extern const NSString * kWilliamsPercentRangePlotSpaceId;
extern const NSString * kRateOfChangePlotSpaceId;
extern const NSString * kMomentumPlotSpaceId;
extern const NSString * kChaikinMoneyFlowPlotSpaceId;
extern const NSString * kComparedSecurityPlotSpaceId;

//061210phien - use external plot to draw main chart
extern const NSString * kLineChartId;
extern const NSString * kOHLCChartId;

extern const NSString * kTrendLinePlot;
extern const NSString * kFibonacciRetracementIdentifier;
extern const NSString * kAndrewPitchforkIdentifier;
extern const NSString * kZeroPercentFibonacci;
extern const NSString * kOneHundredPercentFibonacci;
extern const NSString * kThirdtyEightPercentFibonacci;
extern const NSString * kFiftyPercentFibonacci;
extern const NSString * kSixtyTwoPercentFibonacci;
extern const NSString * kHorizontalAndVerticalThroughPoint;
extern const NSString * kCrossLineForFibExtension;
extern const NSString * kZoomToolRegion;

//221010phien - Trend Line settings
extern const NSString * kSegmentTrendLineColor;
extern const NSString * kSegmentTrendLineThickness;
extern const NSString * kSegmentTrendLineStyle;
extern const NSString * kRayTrendLineColor;
extern const NSString * kRayTrendLineThickness;
extern const NSString * kRayTrendLineStyle;
extern const NSString * kHorizontalTrendLineColor;
extern const NSString * kHorizontalTrendLineThickness;
extern const NSString * kHorizontalTrendLineStyle;
extern const NSString * kHorizontalTrendLineEnablePriceMarker;

extern const NSString * kTrendLineColor;
extern const NSString * kTrendLineThickness;
extern const NSString * kTrendLineExtendHead;

extern const NSString * kFibonacciSetting;

//070111phien - Search Symbols
extern const NSString * kSymbolsInfoPListFileName;
extern const NSString * kSymbolCheckUpdateNow;
extern const NSString * kSymbolLastCheckingUpdateDate;

extern const NSString * kLoadingHistoricalDataLabelText;

//check for first time to save to DB
extern const NSString * kFuturesContractExpirationLoaded;

//time zone
extern const NSString * kNewYorkTimeZone;
extern const NSString * kChicagoTimeZone;

extern const NSString * kAppIdentifier;

extern const NSString * ddfPlusExchangeTypeStock;
extern const NSString * ddfPlusExchangeTypeFuture;
extern const NSString * ddfPlusExchangeTypeForex;
extern const NSString * ddfPlusExchangeTypeIndex;

extern const NSString *kPasswordKeyString;
extern const NSString *kAppDidPurchased;
extern const NSString *kStockIntradayTransactionReceipt;
extern const NSString *kIsStockIntradayPurchased;

extern const NSString *kUsernamePasswordIsIncorrect;
extern const NSString *kUsernameNotAllowedMessage;
extern const NSString *kUsernameExpiredMessage;
extern const NSString *kUsernameBlockedMessage;

extern const NSString *kDisclaimerAgreement;

extern const NSString *kTemplateIChartistDNS;

extern const NSString *kFlurryAPIChartScreen;
extern const NSString *kFlurryAPIChartScreenIndicatorUsage;
extern const NSString *kFlurryAPIQuoteScreenAddSymbol;
extern const NSString *kFlurryAPIIndicatorSettings;
extern const NSString *kFlurryAPIParameterKeyUserType;
extern const NSString *kFlurryAPIParameterKeySymbol;
extern const NSString *kFlurryAPIParameterKeyTimeFrame;
extern const NSString *kFlurryAPIParameterKeyIndicatorName;
extern const NSString *kFlurryAPIChartSettings;
extern const NSString *kCurrentApplicationBundleVersion;


extern const NSString *kAlertViewTitleNoEndOfDayAvailableForSymbol;

extern const NSString *kUserDefaultIsAppInstalled;
extern const NSString *kUserDefaultIsFirstTimeAskToRestore;

@end
