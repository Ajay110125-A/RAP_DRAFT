@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Travel Interface Draft'
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZI_TRAVEL_AY_D
  as select from zaj_travel_d as _Travel

  composition [1..*] of ZI_BOOKING_AY_D          as _Booking

  association [0..1] to /DMO/I_Agency            as _Agency        on _Travel.agency_id = _Agency.AgencyID
  association [0..1] to /DMO/I_Customer          as _Customer      on _Travel.customer_id = _Customer.CustomerID
  association [0..1] to /DMO/I_Overall_Status_VH as _OverallStatus on _Travel.overall_status = _OverallStatus.OverallStatus
  association [0..1] to I_Currency               as _Currency      on _Travel.currency_code = _Currency.Currency
{

  key travel_uuid           as TravelUUID,

      travel_id             as TravelId,
      agency_id             as AgencyId,
      customer_id           as CustomerId,
      begin_date            as BeginDate,
      end_date              as EndDate,
      @Semantics.amount.currencyCode: 'CurrencyCode'
      booking_fee           as BookingFee,
      @Semantics.amount.currencyCode: 'CurrencyCode'
      total_price           as TotalPrice,
      currency_code         as CurrencyCode,
      description           as Description,
      overall_status        as OverallStatus,

      @Semantics.user.createdBy: true
      local_created_by      as LocalCreatedBy,
      @Semantics.systemDateTime.createdAt: true
      local_created_at      as LocalCreatedAt,
      @Semantics.user.lastChangedBy: true
      local_last_changed_by as LocalLastChangedBy,

      //Local ETag field --> Odata Etag
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      local_last_changed_at as LocalLastChangedAt,

      //Total Etag Field
      @Semantics.systemDateTime.lastChangedAt: true
      last_changed_at       as LastChangedAt,

      //    Assocaiations
      _Agency,
      _Customer,
      _OverallStatus,
      _Currency,
      _Booking
}
