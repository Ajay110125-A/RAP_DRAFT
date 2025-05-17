@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Booking Interface Draft'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZI_BOOKING_AY_D
  as select from zaj_booking_d as _Booking

  association        to parent ZI_TRAVEL_AY_D           as _Travel on  $projection.TravelUUID = _Travel.TravelUUID
  composition [0..*] of ZI_BKSUPP_AY_D           as _BookingSup
  
  association [1..1] to /DMO/I_Customer          as _Customer      on  _Booking.customer_id = _Customer.CustomerID
  association [1..1] to /DMO/I_Carrier           as _Carrier       on  _Booking.carrier_id = _Carrier.AirlineID
  association [1..1] to /DMO/I_Connection        as _Connection    on  _Booking.carrier_id    = _Connection.AirlineID
                                                                   and _Booking.connection_id = _Connection.ConnectionID
  association [1..1] to /DMO/I_Booking_Status_VH as _BookingStatus on  _Booking.booking_status = _BookingStatus.BookingStatus
{
  key booking_uuid          as BookingUUID,
      parent_uuid           as TravelUUID,

      booking_id            as BookingId,
      booking_date          as BookingDate,
      customer_id           as CustomerId,
      carrier_id            as CarrierId,
      connection_id         as ConnectionId,
      flight_date           as FlightDate,
      @Semantics.amount.currencyCode: 'CurrencyCode'
      flight_price          as FlightPrice,
      currency_code         as CurrencyCode,
      booking_status        as BookingStatus,

      //Local ETag field --> Odata Etag
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      local_last_changed_at as LocalLastChangedAt,

      // Make association public
      _Travel,
      _BookingSup,
      _Customer,
      _Carrier,
      _Connection,
      _BookingStatus
}
