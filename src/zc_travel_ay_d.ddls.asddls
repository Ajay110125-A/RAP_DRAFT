@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Projection of ZI_TRAVEL_AY_D'
@Metadata.allowExtensions: true
@Search.searchable: true
define root view entity ZC_TRAVEL_AY_D
  provider contract transactional_query
  as projection on ZI_TRAVEL_AY_D
{
  key TravelUUID,

      @Search.defaultSearchElement: true
      TravelId,


      @Search.fuzzinessThreshold: 0.7
      @Search.defaultSearchElement: true
      @ObjectModel.text.element: [ 'AgencyName' ]
      @Consumption.valueHelpDefinition: [{
                                           entity: {
                                                      name: '/DMO/I_Agency_StdVH',
                                                      element: 'AgencyID'
                                                   },
                                           useForValidation: true
                                        }]
      AgencyId,
      _Agency.Name              as AgencyName,


      @Search.fuzzinessThreshold: 0.7
      @Search.defaultSearchElement: true
      @ObjectModel.text.element: [ 'CustomerName' ]
      @Consumption.valueHelpDefinition: [{
                                           entity: {
                                                    name: '/DMO/I_Customer_StdVH',
                                                    element: 'CustomerID'
                                                   },
                                           useForValidation: true
                                         }]
      CustomerId,
      _Customer.LastName        as CustomerName,


      BeginDate,

      EndDate,

      @Semantics.amount.currencyCode: 'CurrencyCode'
      BookingFee,

      @Semantics.amount.currencyCode: 'CurrencyCode'
      TotalPrice,

      @Consumption.valueHelpDefinition: [{
                                            entity: {
                                                      name: 'I_CurrencyStdVH',
                                                      element: 'Currency'
                                                    },
                                            useForValidation: true
                                        }]
      CurrencyCode,

      Description,

      @ObjectModel.text.element: [ 'OverallStatusText' ]
      OverallStatus,
      _OverallStatus._Text.Text as OverallStatusText : localized,


      LocalLastChangedAt,
      /* Associations */
      _Agency,
      _Booking : redirected to composition child ZC_BOOKING_AY_D,
      _Currency,
      _Customer,
      _OverallStatus
}
