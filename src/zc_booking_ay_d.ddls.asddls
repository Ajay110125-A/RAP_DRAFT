@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Booking Projection View Draft'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
@Search.searchable: true
define view entity ZC_BOOKING_AY_D
  //  provider contract transactional_query
  as projection on ZI_BOOKING_AY_D
{
  key BookingUUID,

      TravelUUID,

      @Search.defaultSearchElement: true
      @Search.fuzzinessThreshold: 0.7
      BookingId,

      BookingDate,

      @ObjectModel.text.element: [ 'LastName' ]
      @Search.defaultSearchElement: true
      @Search.fuzzinessThreshold: 0.7
      @Consumption.valueHelpDefinition: [{
                                           entity : {
                                                      name: '/DMO/I_Customer',
                                                      element: 'CustomerID'
                                                    }
                                        }]
      CustomerId,
      _Customer.LastName        as LastName,

      @ObjectModel.text.element: [ 'CarrierName' ]
      @Consumption.valueHelpDefinition: [{
                                           entity:{ name: '/DMO/I_Flight', element: 'AirlineID' },
                                           additionalBinding: [
                                                                { localElement: 'FlightDate',   element: 'FlightDate',   usage: #RESULT },
                                                                { localElement: 'CarrierId',    element: 'AirlineID',    usage: #RESULT },
                                                                { localElement: 'FlightPrice',  element: 'Price',        usage: #RESULT },
                                                                { localElement: 'CurrencyCode', element: 'CurrencyCode', usage: #RESULT }
                                                              ]
                                        }]
      CarrierId,
      _Carrier.Name             as CarrierName,

      @Consumption.valueHelpDefinition: [{
                                           entity:{ name: '/DMO/I_Flight', element: 'ConnectionID' },
                                           additionalBinding: [
                                                                { localElement: 'FlightDate',   element: 'FlightDate' },
                                                                { localElement: 'CarrierId',    element: 'AirlineID'  },
                                                                { localElement: 'FlightPrice',  element: 'Price',        usage: #RESULT },
                                                                { localElement: 'CurrencyCode', element: 'CurrencyCode', usage: #RESULT }
                                                              ]
                                        }]
      ConnectionId,

      FlightDate,

      @Semantics.amount.currencyCode: 'CurrencyCode'
      @Consumption.valueHelpDefinition: [{
                                           entity:{ name: '/DMO/I_Flight', element: 'Price' },
                                           additionalBinding: [
                                                                { localElement: 'FlightDate',   element: 'FlightDate' },
                                                                { localElement: 'CarrierId',    element: 'AirlineID'  },
                                                                { localElement: 'FlightPrice',  element: 'Price',        usage: #RESULT },
                                                                { localElement: 'CurrencyCode', element: 'CurrencyCode', usage: #RESULT }
                                                              ]
                                        }]
      FlightPrice,

      @Consumption.valueHelpDefinition: [{
                                            entity: {
                                                      name: 'I_CurrencyStdVH',
                                                      element: 'Currency'
                                                    },
                                            useForValidation: true
                                        }]
      CurrencyCode,
      
      
      @Consumption.valueHelpDefinition: [{  
                                            entity: { 
                                                      name: '/DMO/I_Booking_Status_VH',
                                                      element: 'BookingStatus'
                                                    },
                                            useForValidation: true
                                        }]
      @ObjectModel.text.element: [ 'BookingStatusText' ]
      BookingStatus,
      _BookingStatus._Text.Text as BookingStatusText : localized,


      LocalLastChangedAt,


      /* Associations */
      _BookingStatus,
      _BookingSup : redirected to composition child ZC_BKSUPP_AY_D,
      _Carrier,
      _Connection,
      _Customer,
      _Travel     : redirected to parent ZC_TRAVEL_AY_D
}
