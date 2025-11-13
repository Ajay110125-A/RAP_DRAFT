@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Booking Supp Projection Draft'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
@Search.searchable: true
define view entity ZC_BKSUPP_AY_D
  as projection on ZI_BKSUPP_AY_D
{
  key BookSupplUUID,

      TravelUUID,

      BookingUUID,

//      @Search.defaultSearchElement: true
//      @Search.fuzzinessThreshold: 0.7
//      BookingSupplementId,

      @ObjectModel.text.element: [ 'SupplimentText' ]
      @Consumption.valueHelpDefinition: [{
                                           entity:{
                                                    name: '/DMO/I_Supplement_StdVH',
                                                    element: 'SupplementID'
                                                  },
                                           additionalBinding: [
                                                               { localElement: 'Price',        element: 'Price',        usage: #RESULT },
                                                               { localElement: 'CurrencyCode', element: 'CurrencyCode', usage: #RESULT }
                                                              ]
                                        }]
      SupplementId,
      _SupplementText.Description as SupplimentText : localized,

      @Semantics.amount.currencyCode: 'CurrencyCode'
      Price,

      @Consumption.valueHelpDefinition: [{
                                            entity: {
                                                      name: 'I_CurrencyStdVH',
                                                      element: 'Currency'
                                                    },
                                            useForValidation: true
                                        }]
      CurrencyCode,


      LocalLastChangedAt,
      /* Associations */
      _Booking : redirected to parent ZC_BOOKING_AY_D,
      _Product,
      _SupplementText,
      _Travel  : redirected to ZC_TRAVEL_AY_D
}
