//
//  DataConstants.m
//  ChartPad
//
//  Created by administrator on 9/21/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "Constants.h"


@implementation Constants

NSString * const kCustomNavyTheme                   = @"Navy";
NSString * const kCustomSlateGradientTheme          = @"Slate Gradient";
NSString * const kCurrentTimeZoneName               = @"kCurrentTimeZoneName";
NSString * const kCurrentTimeZone                   = @"kCurrentTimeZone";
NSString * const kCurrentSymbol                     = @"kCurrentSymbol";
NSString * const kCurrentLocation                   = @"kCurrentLocation";
NSString * const kCurrentBarWidth                   = @"kCurrentBarWidth";
NSString * const kCurrentBarSpacing                 = @"kCurrentBarSpacing";
NSString * const kChartObjects                      = @"kChartObjects";
NSString * const kChartObjectsUsingNSDictionary     = @"kChartObjectsUsingNSDictionary";
NSString * const kOpenCurrentWidth                  = @"kOpenCurrentWidth";
NSString * const kOpenCurrentThickness              = @"kOpenCurrentThickness";
NSString * const kCloseCurrentWidth                 = @"kCloseCurrentWidth";
NSString * const kCloseCurrentThickness             = @"kCloseCurrentThickness";
NSString * const kTimeScaleList                     = @"kTimeScaleList";
NSString * const kCurrentTimeScale                  = @"kCurrentTimeScale";

NSString * const kUserUtilityUsername					= @"kUserUtilityUsername";
NSString * const kUserUtilityPassword					= @"kUserUtilityPassword";
NSString * const kUsernameExpiredDate					= @"kUsernameExpiredDate";
NSString * const kResetUsernameAndPassword				= @"kResetUsernameAndPassword";
NSString * const kUserSettingsDefaultStreamingHost      = @"kUserSettingsDefaultStreamingHost";
NSString * const kUserSettingsDefaultPrimaryHistoricalv2Host = @"kUserSettingsDefaultPrimaryHistoricalv2Host";
NSString * const kUserSettingsDefaultSecondaryHistoricalv2Host = @"kUserSettingsDefaultSecondaryHistoricalv2Host";

NSString * const kSocketErrorNotification				= @"socketErrorNotification";
NSString * const kSocketDisconnectNotification			= @"socketDisconnectNotification";
NSString * const kSocketReturnNotification				= @"socketReturnNotification";
NSString * const kTimestampReturnNotification			= @"timestampReturnNotification";

NSString * const kLoggingNotification						= @"loggingNotification";
NSString * const kInvalidLoginNotification					= @"invalidLoginNotification";
NSString * const kSuccessLoginNotification					= @"successLoginNotification";
NSString * const kDualLoginNotification						= @"dualLoginNotification";
NSString * const kUsernameExpirationNotification			= @"usernameExpirationNotification";
NSString * const kChangeViewControllerNotification			= @"changeViewControllerNotification";
NSString * const kStopStreamOutsideOfSessionNotification	= @"stopStreamOutsideOfSessionNotification";

NSString * const kQuoteScreenLoginSuccessfulNotification=@"quoteScreenLoginSuccessfulNotification";

NSString * const kOperationFilterContentSearchTextDoneNotification	= @"operationFilterContentSearchTextDoneNotification";
NSString * const kShouldMergeQuoteEntriesFromiCloudNotification     = @"shouldMergeQuoteEntriesFromiCloudNotification";
NSString * const kShouldReloadDefaultChartSettingsNotification      = @"shouldReloadDefaultChartSettingsNotification";

NSString * const kInitialQuoteEntries                    = @"InitialQuoteEntries";

const NSString * kSymbol = @"symbol";
const NSString * kExtendedStartDate = @"extendedStartDate";
const NSString * kStartDate = @"startDate";
const NSString * kEndDate = @"endDate";
const NSString * kOverallHigh = @"overallHigh";
const NSString * kOverallLow = @"overallLow";
const NSString * kOverallVolumeHigh = @"overallVolumeHigh";
const NSString * kOverallVolumeLow = @"overallVolumeLow";
const NSString * kFinancialData = @"financialData";
const NSString * kExtendedData = @"extendedData";

const NSString * kSymbolKey = @"Symbol";
const NSString * kCompanyNameKey = @"CompanyName";
const NSString * kLastTradeKey = @"LastTrade";
const NSString * kLastChangeKey = @"LastChange";


//for chart objects identifier
const NSString * kMovingAverageIdentifier				= @"Moving Average";
const NSString * kBollingerBandsId						= @"Bollinger Bands";
const NSString * kDonchianBands							= @"Donchian Bands";
const NSString * kKeltnerChannelsIdentifier				= @"Keltner Channels";
const NSString * kParabolicSAR							= @"Parabolic SAR";
const NSString * kMovingAverageEnvelopes				= @"MA Envelopes";
const NSString * kPivotPoints							= @"Pivot Points";
const NSString * kVolumeByPriceId                       = @"Volume By Price";

const NSString * kAccumulationDistributionId            = @"AccumulationDistributionLine";
const NSString * kChaikinOscillatorId                   = @"ChaikinOscillator";
const NSString * kAbsolutePriceOscillatorId             = @"AbsolutePriceOscillator";
const NSString * kAroonId                               = @"Aroon";
const NSString * kAroonOscillatorId                     = @"AroonOscillator";
const NSString * kBalanceOfPowerId                      = @"BalanceOfPower";
const NSString * kChaideMomentumOscillatorId            = @"ChaideMomentumOscillator";
const NSString * kDirectionalMovementIndexId            = @"DirectionalMovementIndex";
const NSString * kMoneyFlowIndexId                      = @"MoneyFlowIndex";
const NSString * kPercentagePriceOscillatorId           = @"PercentagePriceOscillator";
const NSString * kStandardDeviationId                   = @"StandardDeviation";
const NSString * kStochasticRelativeStrengthIndexId     = @"StochasticRelativeStrengthIndex";
const NSString * kSummationId                           = @"Summation";
const NSString * kTimeSeriesForecastId                  = @"TimeSeriesForecast";
const NSString * kROCofTEMAId                           = @"RateOfChangeOfTEMA";
const NSString * kVolumeIdentifier						= @"Volume";
const NSString * kMACDId								= @"MACD";
const NSString * kStochasticsFastIdentifier				= @"Stochastic Fast"; 
const NSString * kStochasticsSlowIdentifier				= @"Stochastic Slow";
const NSString * kAverageDirectionalRatingId            = @"AverageDirectionalRating";
const NSString * kAverageDirectionalIndex				= @"Average Directional Index";
const NSString * kRelativeStrengthIndex					= @"Relative Strength Index";
const NSString * kCommodityChannelIndex					= @"Commodity Channel Index";
const NSString * kAverageTrueRange						= @"Average True Range";
const NSString * kOnBalanceVolume						= @"On Balance Volume";
const NSString * kWilliamsPercentRange					= @"Williams Percent Range";
const NSString * kRateOfChange							= @"Rate Of Change";
const NSString * kMomentum								= @"Momentum";
const NSString * kChaikinMoneyFlow						= @"Chaikin Money Flow";
const NSString * kComparedSecurity						= @"Compared Security";

const NSString * kVolumePlotSpaceId						= @"Volume Plot Space";
const NSString * kMACDPlotSpaceId						= @"MACD Plot Space";
const NSString * kStochasticsFastPlotSpaceId			= @"Stochastics Fast Plot Space";
const NSString * kStochasticsSlowPlotSpaceId			= @"Stochastics Slow Plot Space";
const NSString * kAverageDirectionalIndexPlotSpaceId	= @"Average Directional Index Plot Space";
const NSString * kRelativeStrengthIndexPlotSpaceId		= @"Relative Strength Index Plot Space";
const NSString * kCommodityChannelIndexPlotSpaceId		= @"Commodity Channel Index Plot Space";
const NSString * kAverageTrueRangePlotSpaceId			= @"Average True Range Plot Space";
const NSString * kOnBalanceVolumePlotSpaceId			= @"On Balance Volume Plot Space";
const NSString * kWilliamsPercentRangePlotSpaceId		= @"Williams Percent Range Plot Space";
const NSString * kRateOfChangePlotSpaceId				= @"Rate Of Change Plot Space";
const NSString * kMomentumPlotSpaceId					= @"Momentum Plot Space";
const NSString * kChaikinMoneyFlowPlotSpaceId			= @"Chaikin Money Flow Plot Space";
const NSString * kComparedSecurityPlotSpaceId			= @"Compared Security Plot Space";

const NSString * kLineChartId = @"Line Chart";
const NSString * kOHLCChartId = @"OHLC Chart";

const NSString * kTrendLinePlot = @"Trend Line";
const NSString * kFibonacciRetracementIdentifier = @"Fibonacci Retracement";
const NSString * kAndrewPitchforkIdentifier = @"Andrew Pitchfork";
const NSString * kZeroPercentFibonacci = @"Zero Percent Fibonacci Retracement Line Plot";
const NSString * kOneHundredPercentFibonacci = @"One Hundred Percent Fibonacci Retracement Line Plot";
const NSString * kThirdtyEightPercentFibonacci = @"Thirdty Eight Percent Fibonacci Retracement Line Plot";
const NSString * kFiftyPercentFibonacci = @"Fifty Percent Fibonacci Retracement Line Plot";
const NSString * kSixtyTwoPercentFibonacci = @"Sixty Two Percent Fibonacci Retracement Line Plot";
const NSString * kHorizontalAndVerticalThroughPoint = @"Horizontal And Vertical Through Touch Point";
const NSString * kZoomToolRegion					= @"ZoomToolRegion";

//221010phien - Trend Line settings
const NSString * kSegmentTrendLineColor					= @"keySegmentTrendLineColor";
const NSString * kSegmentTrendLineThickness				= @"keySegmentTrendLineThickness";
const NSString * kSegmentTrendLineStyle					= @"keySegmentTrendLineStyle";
const NSString * kRayTrendLineColor						= @"keyRayTrendLineColor";
const NSString * kRayTrendLineThickness					= @"keyRayTrendLineThickness";
const NSString * kRayTrendLineStyle						= @"keyRayTrendLineStyle";
const NSString * kHorizontalTrendLineColor				= @"keyHorizontalTrendLineColor";
const NSString * kHorizontalTrendLineThickness			= @"keyHorizontalTrendLineThickness";
const NSString * kHorizontalTrendLineStyle				= @"keyHorizontalTrendLineStyle";
const NSString * kHorizontalTrendLineEnablePriceMarker  = @"kHorizontalTrendLineEnablePriceMarker";
const NSString * kCrossLineForFibExtension				= @"keyCrossLineForFibExtension";

const NSString * kTrendLineColor						= @"kTrendLineColor";
const NSString * kTrendLineThickness					= @"kTrendLineThickness";
const NSString * kTrendLineExtendHead					= @"kTrendLineExtendedHead";

const NSString * kFibonacciSetting = @"keyFibonacciSetting";

//070111phien - Search Symbols
const NSString * kSymbolsInfoPListFileName		= @"symbols_info";
const NSString * kSymbolCheckUpdateNow			= @"Symbol Check Update Now";
const NSString * kSymbolLastCheckingUpdateDate	= @"Symbol Last Checking Update Date";

const NSString * kLoadingHistoricalDataLabelText= @"Downloading data";

const NSString * kFuturesContractExpirationLoaded	= @"keyFuturesContractExpirationLoaded";

const NSString * kNewYorkTimeZone		= @"America/New_York";
const NSString * kChicagoTimeZone		= @"America/Chicago";

const NSString * kAppIdentifier			= @"© 2011 iChartist.com";

const NSString * ddfPlusExchangeTypeStock	= @"Stock";
const NSString * ddfPlusExchangeTypeFuture	= @"Future";
const NSString * ddfPlusExchangeTypeForex	= @"Forex";
const NSString * ddfPlusExchangeTypeIndex	= @"Index";

const NSString *kPasswordKeyString					= @"agilemobile";
const NSString *kAppDidPurchased					= @"keyAppDidPurchased";
const NSString *kStockIntradayTransactionReceipt	= @"StockIntradayTransactionReceipt";
const NSString *kIsStockIntradayPurchased			= @"isStockIntradayPurchased";

const NSString *kUsernamePasswordIsIncorrect    = @"The username or password you entered is incorrect";
const NSString *kUsernameNotAllowedMessage		= @"The username you entered is not authorized for realtime data access. Please contact support@ichartist.com for assistance.";
const NSString *kUsernameExpiredMessage			= @"The username you entered is not authorized for realtime data access. Please contact support@ichartist.com for assistance.";
const NSString *kUsernameBlockedMessage			= @"The username you entered is blocked. Please contact support@ichartist.com for assistance.";

const NSString *kDisclaimerAgreement		= @"Disclaimer Agreement";
const NSString *kTemplateIChartistDNS		= @"chartpad.agilemobile.com";

const NSString *kFlurryAPIChartScreen					= @"Chart Screen";
const NSString *kFlurryAPIChartScreenIndicatorUsage		= @"Chart Screen - Indicator Usage";
const NSString *kFlurryAPIQuoteScreenAddSymbol			= @"Quote Screen - Add Symbol";
const NSString *kFlurryAPIIndicatorSettings				= @"Indicator";
const NSString *kFlurryAPIParameterKeyUserType			= @"User Type";
const NSString *kFlurryAPIParameterKeySymbol			= @"Symbol";
const NSString *kFlurryAPIParameterKeyTimeFrame			= @"Time Frame";
const NSString *kFlurryAPIParameterKeyIndicatorName		= @"Indicator Name";
const NSString *kFlurryAPIChartSettings					= @"Chart Settings";
const NSString *kCurrentApplicationBundleVersion		= @"Current Application Bundle Version";


const NSString *kAlertViewTitleNoEndOfDayAvailableForSymbol	= @"No End of Day data available for";
const NSString *kUserDefaultIsAppInstalled                  = @"User Default Is App Installed";
const NSString *kUserDefaultIsFirstTimeAskToRestore         = @"User Default Is First Time Ask To Restore";

@end