@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Booking Suppliment Interface Draft'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZI_BKSUPP_AY_D
  as select from zaj_bksupp_d as _BookingSup
  association        to parent ZI_BOOKING_AY_D as _Booking        on $projection.BookingUUID = _Booking.BookingUUID
  association [1..1] to ZI_TRAVEL_AY_D         as _Travel         on $projection.TravelUUID = _Travel.TravelUUID
  association [1..1] to /DMO/I_Supplement      as _Product        on _BookingSup.supplement_id = _Product.SupplementID
  association [1..*] to /DMO/I_SupplementText  as _SupplementText on _BookingSup.supplement_id = _SupplementText.SupplementID
{
  key booksuppl_uuid        as BookSupplUUID,
      root_uuid             as TravelUUID,
      parent_uuid           as BookingUUID,
      booking_supplement_id as BookingSupplementId,
      supplement_id         as SupplementId,
      @Semantics.amount.currencyCode: 'CurrencyCode'
      price                 as Price,
      currency_code         as CurrencyCode,

      //Local ETag field --> Odata ETag
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      local_last_changed_at as LocalLastChangedAt,

      //Association
      _Booking,
      _Travel,

      _Product,
      _SupplementText
}
