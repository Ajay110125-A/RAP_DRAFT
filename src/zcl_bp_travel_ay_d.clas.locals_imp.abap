CLASS lhc__Travel DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR _Travel RESULT result.
    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR _travel RESULT result.
    METHODS precheck_create FOR PRECHECK
      IMPORTING entities FOR CREATE _travel.

    METHODS precheck_update FOR PRECHECK
      IMPORTING entities FOR UPDATE _travel.
    METHODS accepttravel FOR MODIFY
      IMPORTING keys FOR ACTION _travel~accepttravel RESULT result.

    METHODS discount FOR MODIFY
      IMPORTING keys FOR ACTION _travel~discount RESULT result.

    METHODS rejecttravel FOR MODIFY
      IMPORTING keys FOR ACTION _travel~rejecttravel RESULT result.
    METHODS recaltotalprice FOR MODIFY
      IMPORTING keys FOR ACTION _travel~recaltotalprice.
    METHODS caltotalprice FOR DETERMINE ON MODIFY
      IMPORTING keys FOR _travel~caltotalprice.

    METHODS setstatus FOR DETERMINE ON MODIFY
      IMPORTING keys FOR _travel~setstatus.

    METHODS settravelid FOR DETERMINE ON SAVE
      IMPORTING keys FOR _travel~settravelid.
    METHODS validatecustomerid FOR VALIDATE ON SAVE
      IMPORTING keys FOR _travel~validatecustomerid.
    METHODS validateagency FOR VALIDATE ON SAVE
      IMPORTING keys FOR _travel~validateagency.
    METHODS validatebegindate FOR VALIDATE ON SAVE
      IMPORTING keys FOR _travel~validatebegindate.
    METHODS validateenddate FOR VALIDATE ON SAVE
      IMPORTING keys FOR _travel~validateenddate.
    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR _travel RESULT result.

ENDCLASS.

CLASS lhc__Travel IMPLEMENTATION.

  METHOD get_instance_authorizations.

**********************************************************************

*    IF CURD disabling and enabling based on the line items in Ui5 then we need to implement this method so that we can apply on every row using Key fields done below
*    Here Check happens only using keys. And if to check should happen on user inputs then Pre check should be implemented
**********************************************************************
    DATA: l_delete LIKE if_abap_behv=>auth-allowed,
          l_update LIKE if_abap_behv=>auth-allowed.


    READ ENTITIES OF zi_travel_ay_d IN LOCAL MODE
       ENTITY _Travel
       FIELDS ( OverallStatus AgencyId )
       WITH CORRESPONDING #( keys )
       RESULT DATA(lt_travels)
       FAILED failed.

    CHECK lt_travels IS NOT INITIAL.

*    SELECT
*      FROM zaj_travel_d AS t
*      INNER JOIN /dmo/agency AS a
*      ON t~agency_id = a~agency_id
*      FIELDS t~travel_uuid, t~agency_id, a~country_code
*      FOR ALL ENTRIES IN @lt_travels
*      WHERE t~travel_uuid = @lt_travels-%key-TravelUUID
*      INTO TABLE @DATA(lt_agency_city).

    LOOP AT lt_travels INTO DATA(lwa_travels).

*       IF lwa_travels-%data-OverallStatus = 'A'.
*
*        result = VALUE #( BASE result
*                          (
*                            %tky = lwa_travels-%tky
*                            %delete = if_abap_behv=>auth-unauthorized
*                          )
*                        ).
*       ELSEIF lwa_travels-%data-OverallStatus = 'X'.
*
*        result = VALUE #( BASE result
*                          (
*                            %tky = lwa_travels-%tky
**                            %delete = if_abap_behv=>auth-unauthorized
*                          )
*                        ).
*
*       ENDIF.

*      READ TABLE lt_agency_city ASSIGNING FIELD-SYMBOL(<fs_age_cnty>) WITH KEY travel_uuid = lwa_travels-%key-TravelUUID.
*      IF sy-subrc EQ 0.
*
*        IF requested_authorizations-%update = if_abap_behv=>mk-on.
*
**          AUTHORITY-CHECK OBJECT '/DMO/TRAVL'
**          ID '/DMO/CNTRY' FIELD <fs_age_cnty>-country_code
**          ID 'ACTVT' FIELD  '02'.
*
*          l_update = COND #(
*                                   WHEN sy-subrc EQ 0 THEN if_abap_behv=>auth-allowed
*                                    ELSE if_abap_behv=>auth-unauthorized
*                                 ).
*          IF l_update EQ if_abap_behv=>auth-unauthorized.
*
*            failed-_travel = VALUE #( BASE failed-_travel
*                                      (
*                                       %tky     = lwa_travels-%tky
*                                       %update  = if_abap_behv=>mk-on
*                                      )
*                                    ).
*
*            reported-_travel = VALUE #( BASE reported-_travel
*                                         (
*                                           %tky = lwa_travels-%tky
*                                           %msg = NEW /dmo/cm_flight_messages(
*                                                                                textid    = /dmo/cm_flight_messages=>not_authorized_for_agencyid
*                                                                                agency_id = lwa_travels-%data-AgencyId
*                                                                                severity  = if_abap_behv_message=>severity-error
*                                                                             )
*                                           %element-agencyid = if_abap_behv=>mk-on
*                                         )
*
*                                      ).
*
*          ENDIF.
*
*        ENDIF.
*
*        IF requested_authorizations-%delete = if_abap_behv=>mk-on.
*
**          AUTHORITY-CHECK OBJECT '/DMO/TRAVL'
**             ID '/DMO/CNTRY' FIELD <fs_age_cnty>-country_code
**             ID 'ACTVT' FIELD  '06'.
*
*          l_delete = COND #(
*                                    WHEN sy-subrc EQ 0 THEN if_abap_behv=>auth-allowed
*                                     ELSE if_abap_behv=>auth-unauthorized
*                                 ).
*
*          IF l_delete EQ if_abap_behv=>auth-unauthorized.
*
*            failed-_travel = VALUE #(  BASE failed-_travel
*                                     (
*                                       %tky     = lwa_travels-%tky
*                                       %delete  = if_abap_behv=>mk-on
*                                      )
*                                    ).
*
*            reported-_travel = VALUE #( BASE reported-_travel
*                                         (
*                                           %tky = lwa_travels-%tky
*                                           %msg = NEW /dmo/cm_flight_messages(
*                                                                                textid    = /dmo/cm_flight_messages=>not_authorized_for_agencyid
*                                                                                agency_id = lwa_travels-%data-AgencyId
*                                                                                severity  = if_abap_behv_message=>severity-error
*                                                                             )
*                                           %element-agencyid = if_abap_behv=>mk-on
*                                         )
*
*                                      ).
*
*          ENDIF.
*
*        ENDIF.
*
*
*
*      ENDIF.
*
*      result = VALUE #(
*                        BASE result
*                        (
*                          TravelUUID = lwa_travels-%key-TravelUUID
*                          %update = CONV #( '00' ) "l_update
*                          %delete = CONV #( '00' ) "l_delete
*
*                        )
*                      ).
*
*      CLEAR : l_delete, l_update.

    ENDLOOP.

  ENDMETHOD.

  METHOD get_global_authorizations.

    "This code is commented because For Auth Check BTP Trial account user doesn't have auth to add authorization for any values. And user won't be able o edit or update or create any data.
    """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
**********************************************************************

*    This method is used for global disabling of CURD Operation. Means it user fails Auth Check here that user won't be able to do any CURD operation.
*    To enable or disable CURD operation for particular line item then we need to another method get_instance_authorizations.

**********************************************************************

*    IF requested_authorizations-%create = if_abap_behv=>mk-on.
*
*      AUTHORITY-CHECK OBJECT '/DMO/TRAVl'
*          ID '/DMO/CNTRY' DUMMY
*          ID 'ACTVT' FIELD  '01'.
*
*      result-%create = COND #(
*                                WHEN sy-subrc EQ 0 THEN if_abap_behv=>auth-allowed
*                                ELSE if_abap_behv=>auth-unauthorized
*                             ).
*
*    ENDIF.
*    IF requested_authorizations-%update = if_abap_behv=>mk-on.
*
*      AUTHORITY-CHECK OBJECT '/DMO/TRAVl'
*          ID '/DMO/CNTRY' DUMMY
*          ID 'ACTVT' FIELD  '02'.
*
*
*      result-%update = COND #(
*                                 WHEN sy-subrc EQ 0 THEN if_abap_behv=>auth-allowed
*                                 ELSE if_abap_behv=>auth-unauthorized
*                              ).
*
*    ENDIF.
*    IF requested_authorizations-%delete = if_abap_behv=>mk-on.
*
*      AUTHORITY-CHECK OBJECT '/DMO/TRAVl'
*          ID '/DMO/CNTRY' DUMMY
*          ID 'ACTVT' FIELD  '06'.
*
*      result-%delete = COND #(
*                                 WHEN sy-subrc EQ 0 THEN if_abap_behv=>auth-allowed
*                                 ELSE if_abap_behv=>auth-unauthorized
*                              ).
*
*
*    ENDIF.


  ENDMETHOD.

  METHOD precheck_create.

**********************************************************************
*    This method to validate the incoming values from users which creating a travel
**********************************************************************

  ENDMETHOD.

  METHOD precheck_update.
**********************************************************************
*    This Pre-Check is done only for Agency ID, this code works only if users changes the agency ID using Ui5. This method can be used for all values users changes at UI5.
**********************************************************************

    DATA : lt_agencyids TYPE SORTED TABLE OF /dmo/agency WITH UNIQUE KEY agency_id.

    lt_agencyids = CORRESPONDING #( entities MAPPING  agency_id = AgencyId EXCEPT * ).

    CHECK lt_agencyids IS NOT INITIAL.

    SELECT
        FROM /dmo/agency
        FIELDS agency_id, country_code
        FOR ALL ENTRIES IN @lt_agencyids
        WHERE agency_id = @lt_agencyids-agency_id
        INTO TABLE @DATA(lt_agency).
    IF sy-subrc EQ 0.

      LOOP AT entities ASSIGNING FIELD-SYMBOL(<fs_entity>).

        READ TABLE lt_agency ASSIGNING FIELD-SYMBOL(<fs_agency>) WITH KEY agency_id = <fs_entity>-%data-AgencyId.


*        AUTHORITY-CHECK OBJECT '/DMO/TRAVl'
*           ID '/DMO/CNTRY' FIELD <fs_agency>-country_code
*           ID 'ACTVT' FIELD  '06'.
        IF sy-subrc NE 0.

          failed-_travel = VALUE #(
                                    BASE failed-_travel
                                    ( %tky = <fs_entity>-%tky )
                                  ).

          reported-_travel = VALUE #(
                                      BASE  reported-_travel
                                      (
                                        %tky = <fs_entity>-%tky
                                        %msg = NEW /dmo/cm_flight_messages(
                                                                              textid                = /dmo/cm_flight_messages=>not_authorized_for_agencyid
                                                                              agency_id             = <fs_entity>-%data-AgencyId
                                                                              severity              = if_abap_behv_message=>severity-error
                                                                          )
                                      %element-%field-AgencyId = if_abap_behv=>mk-on
                                      )
                                    ).

        ENDIF.


      ENDLOOP.

    ENDIF.


  ENDMETHOD.

  METHOD acceptTravel.

    MODIFY ENTITIES OF zi_travel_ay_d IN LOCAL MODE
     ENTITY _Travel
     UPDATE FIELDS ( OverallStatus )
     WITH VALUE #(
                    FOR lwa_keys IN keys
                    (
                     %tky = lwa_keys-%tky
                     OverallStatus = 'A'
                    )
                 ).

    READ ENTITIES OF zi_travel_ay_d IN LOCAL MODE
     ENTITY _Travel
     ALL FIELDS WITH CORRESPONDING #( keys )
     RESULT DATA(lt_travels).

    result = VALUE #(
                      FOR lwa_travels IN lt_travels
                      (
                         %tky = lwa_travels-%tky
                         %param = lwa_travels
                      )
                    ).



  ENDMETHOD.

  METHOD discount.

    DATA(lt_keys) = keys.

    LOOP AT lt_keys ASSIGNING FIELD-SYMBOL(<fs_keys>) WHERE %param-discount IS INITIAL
                                                         OR %param-discount NOT BETWEEN 1 AND 100.

      APPEND VALUE #( %tky = <fs_keys>-%tky ) TO failed-_travel.
      APPEND VALUE #(
                      %tky = <fs_keys>-%tky
                      %msg = NEW /dmo/cm_flight_messages(
                                    textid                = /dmo/cm_flight_messages=>discount_invalid
                                    severity              = if_abap_behv_message=>severity-error
                                  )
                      %element-bookingfee = if_abap_behv=>mk-on
                      %action-discount    = if_abap_behv=>mk-on

                    ) TO reported-_travel.

    ENDLOOP.

    DELETE lt_keys WHERE %param-discount IS INITIAL OR %param-discount NOT BETWEEN 1 AND 100.

    CHECK lt_keys IS NOT INITIAL.

    READ ENTITIES OF zi_travel_ay_d IN LOCAL MODE
     ENTITY _Travel
     FIELDS ( BookingFee )
     WITH CORRESPONDING #( lt_keys )
     RESULT DATA(lt_travel).

    DATA : l_dis_val     TYPE decfloat16,
           lt_travel_new TYPE TABLE FOR UPDATE zi_travel_ay_d.

    LOOP AT lt_travel ASSIGNING FIELD-SYMBOL(<fs_travel>).

      CLEAR l_dis_val.

      DATA(l_discount) = lt_keys[ KEY id %tky = <fs_travel>-%tky ]-%param-discount.

      l_dis_val = <fs_travel>-BookingFee * ( l_discount / 100 ).

      <fs_travel>-BookingFee -= l_dis_val.

      lt_travel_new = VALUE #( ( CORRESPONDING #( <fs_travel> ) ) ).

    ENDLOOP.

    MODIFY ENTITIES OF zi_travel_ay_d IN LOCAL MODE
     ENTITY _Travel
     UPDATE FIELDS ( BookingFee )
     WITH lt_travel_new.

    READ ENTITIES OF zi_travel_ay_d IN LOCAL MODE
     ENTITY _Travel
     ALL FIELDS WITH CORRESPONDING #( lt_keys )
     RESULT DATA(lt_updated_Travel).

    result = VALUE #(
                      FOR lwa_travel IN lt_updated_travel
                         (
                           %tky = lwa_travel-%tky
                           %param = lwa_travel
                         )
                    ).

  ENDMETHOD.

  METHOD rejectTravel.

    MODIFY ENTITIES OF zi_travel_ay_d IN LOCAL MODE
     ENTITY _Travel
     UPDATE FIELDS ( OverallStatus )
     WITH VALUE #(
                   FOR lwa_keys IN keys
                   (
                    %tky = lwa_keys-%tky
                    OverallStatus = 'X'
                   )
                 ).

    READ ENTITIES OF zi_travel_ay_d IN LOCAL MODE
     ENTITY _Travel
     ALL FIELDS WITH CORRESPONDING #( keys )
     RESULT DATA(lt_travels).

    result = VALUE #(
                      FOR lwa_travels IN lt_travels
                      (
                         %tky = lwa_travels-%tky
                         %param = lwa_travels
                      )
                    ).

  ENDMETHOD.

  METHOD reCalTotalPrice.

    DATA : l_total_price TYPE /dmo/total_price.

    READ ENTITIES OF zi_travel_ay_d IN LOCAL MODE
     ENTITY _Travel
     FIELDS ( BookingFee TotalPrice )
     WITH CORRESPONDING #( keys )
     RESULT DATA(lt_travel)

     ENTITY _Travel BY \_Booking
     FIELDS ( TravelUUID FlightPrice )
     WITH CORRESPONDING #( keys )
     RESULT DATA(lt_bookings).

    READ ENTITIES OF zi_travel_ay_d IN LOCAL MODE
     ENTITY _Booking BY \_BookingSup
     FIELDS ( TravelUUID BookingUUID Price )
     WITH CORRESPONDING #( lt_bookings )
     RESULT DATA(lt_booking_sup).


    LOOP AT lt_travel ASSIGNING FIELD-SYMBOL(<fs_travel>).

      CLEAR : l_total_price.

      l_total_price += <fs_travel>-%data-BookingFee.

      LOOP AT lt_bookings ASSIGNING FIELD-SYMBOL(<fs_bookings>)
                          WHERE TravelUUID = <fs_travel>-%data-TravelUUID.

        l_total_price += <fs_bookings>-%data-FlightPrice.

        LOOP AT lt_booking_sup ASSIGNING FIELD-SYMBOL(<fs_booking_sup>)
                               WHERE TravelUUID = <fs_travel>-%data-TravelUUID
                               AND   BookingUUID = <fs_bookings>-%data-BookingUUID.
          l_total_price += <fs_booking_sup>-%data-Price.
        ENDLOOP.

      ENDLOOP.

      <fs_travel>-%data-TotalPrice = l_total_price.

    ENDLOOP.

    MODIFY ENTITIES OF zi_travel_ay_d IN LOCAL MODE
     ENTITY _Travel
     UPDATE FIELDS ( TotalPrice )
     WITH VALUE #(
                   FOR lwa_travels IN lt_travel
                   (
                     %tky = lwa_travels-%tky
                     %data-TotalPrice = lwa_travels-%data-TotalPrice
                   )
                 ).

  ENDMETHOD.

  METHOD calTotalPrice.

    MODIFY ENTITIES OF zi_travel_ay_d IN LOCAL MODE
     ENTITY _Travel
     EXECUTE reCalTotalPrice
     FROM CORRESPONDING #( keys ).

  ENDMETHOD.

  METHOD setStatus.

    READ ENTITIES OF zi_travel_ay_d IN LOCAL MODE
      ENTITY _Travel
      FIELDS ( OverallStatus )
      WITH CORRESPONDING #( keys )
      RESULT DATA(lt_travel).

    DELETE lt_travel WHERE OverallStatus IS NOT INITIAL.

    CHECK lt_travel IS NOT INITIAL.

    MODIFY ENTITIES OF zi_travel_ay_d IN LOCAL MODE
      ENTITY _Travel
      UPDATE FIELDS ( OverallStatus )
      WITH VALUE #(
                    FOR lwa_travels IN lt_travel
                      (
                        %tky = lwa_travels-%tky
                        OverallStatus = 'O'
                      )
                  ).


  ENDMETHOD.

  METHOD setTravelId.

    READ ENTITIES OF zi_travel_ay_d IN LOCAL MODE
      ENTITY _Travel
      FIELDS ( TravelId )
      WITH CORRESPONDING #( keys )
      RESULT DATA(lt_travel).

    DELETE lt_travel WHERE TravelId IS NOT INITIAL.

    CHECK lt_travel IS NOT INITIAL.

    SELECT
     FROM zaj_travel_d
     FIELDS MAX( travel_id )
     INTO @DATA(l_max_travelid).

    MODIFY ENTITIES OF zi_travel_ay_d IN LOCAL MODE
      ENTITY _Travel
      UPDATE FIELDS ( TravelId )
      WITH VALUE #(
                    FOR lwa_travels IN lt_travel INDEX INTO l_index
                      (
                        %tky = lwa_travels-%tky
                        TravelId = l_max_travelid + l_index
                      )
                  ).

  ENDMETHOD.

  METHOD validateCustomerID.

    DATA : lt_customer TYPE SORTED TABLE OF /dmo/customer WITH UNIQUE KEY customer_id.

    READ ENTITIES OF zi_travel_ay_d IN LOCAL MODE
      ENTITY _Travel
      FIELDS ( CustomerId )
      WITH CORRESPONDING #( keys )
      RESULT DATA(lt_travels).

    lt_customer = CORRESPONDING #( lt_travels DISCARDING DUPLICATES MAPPING customer_id = CustomerId EXCEPT * ).

    DELETE lt_customer WHERE customer_id IS INITIAL.

    IF lt_customer IS NOT INITIAL.

      SELECT
        FROM /dmo/customer
        FIELDS customer_id
        FOR ALL ENTRIES IN @lt_customer
        WHERE customer_id = @lt_customer-customer_id
        INTO TABLE @DATA(lt_valid_customers).

    ENDIF.

    LOOP AT lt_travels ASSIGNING FIELD-SYMBOL(<fs_travel>).

      reported-_travel = VALUE #( BASE reported-_travel
                                 (
                                    %tky = <fs_travel>-%tky
                                    %state_area = 'VALIDATE_CUSTOMER'
                                 )
                                ).

      IF <fs_travel>-%data-CustomerId IS INITIAL.

        failed-_travel = VALUE #( BASE failed-_travel
                                 ( %tky = <fs_travel>-%tky )
                                ).

        reported-_travel = VALUE #( BASE reported-_travel
                                    (
                                      %tky = <fs_travel>-%tky
                                      %state_area = 'VALIDATE_CUSTOMER'
                                      %msg = NEW /dmo/cm_flight_messages(
                                                                         textid                = /dmo/cm_flight_messages=>enter_customer_id
                                                                         severity              = if_abap_behv_message=>severity-error
                                                                        )
                                      %element-customerid = if_abap_behv=>mk-on
                                    )
                                  ).
      ELSEIF NOT line_exists( lt_valid_customers[ customer_id = <fs_travel>-%data-CustomerId ] ).

        failed-_travel = VALUE #( BASE failed-_travel
                                 ( %tky = <fs_travel>-%tky )
                                ).

        reported-_travel = VALUE #( BASE reported-_travel
                                    (
                                      %tky = <fs_travel>-%tky
                                      %state_area = 'VALIDATE_CUSTOMER'
                                      %msg = NEW /dmo/cm_flight_messages(
                                                                         textid      = /dmo/cm_flight_messages=>customer_unkown
                                                                         customer_id = <fs_travel>-%data-CustomerId
                                                                         severity    = if_abap_behv_message=>severity-error
                                                                        )
                                      %element-customerid = if_abap_behv=>mk-on
                                    )
                                  ).

      ENDIF.

    ENDLOOP.


  ENDMETHOD.

  METHOD validateAgency.

    DATA : lt_agencies TYPE SORTED TABLE OF /dmo/agency WITH UNIQUE KEY agency_id.

    READ ENTITIES OF zi_travel_ay_d IN LOCAL MODE
      ENTITY _Travel
      FIELDS ( AgencyId )
      WITH CORRESPONDING #( keys )
      RESULT DATA(lt_travels).

    lt_agencies = CORRESPONDING #( lt_travels DISCARDING DUPLICATES MAPPING agency_id = AgencyId EXCEPT * ).

    DELETE lt_agencies WHERE agency_id IS INITIAL.

    IF lt_agencies IS NOT INITIAL.

      SELECT
        FROM /dmo/agency
        FIELDS agency_id
        FOR ALL ENTRIES IN @lt_agencies
        WHERE agency_id = @lt_agencies-agency_id
        INTO TABLE @DATA(lt_valid_agencies).

    ENDIF.

    LOOP AT lt_travels ASSIGNING FIELD-SYMBOL(<fs_travel>).

      reported-_travel = VALUE #( BASE reported-_travel
                                  (
                                    %tky = <fs_travel>-%tky
                                    %state_area = 'INVALID_AGENCY'
                                  )
                                ).

      IF <fs_travel>-%data-AgencyId IS INITIAL.

        failed-_travel = VALUE #( BASE failed-_travel
                                  ( %tky = <fs_travel>-%tky )
                                ).

        reported-_travel = VALUE #(
                                    BASE reported-_travel
                                    (
                                      %tky = <fs_travel>-%tky
                                      %state_area = 'INVALID_AGENCY'
                                      %msg = NEW /dmo/cm_flight_messages(
                                                                          textid                = /dmo/cm_flight_messages=>enter_agency_id
                                                                          severity              = if_abap_behv_message=>severity-error
                                                                        )
                                      %element-agencyid = if_abap_behv=>mk-on
                                    )
                                  ).

      ELSEIF NOT line_exists( lt_valid_agencies[ agency_id = <fs_travel>-%data-AgencyId ] ).

        failed-_travel = VALUE #( BASE failed-_travel
                                  ( %tky = <fs_travel>-%tky )
                                ).

        reported-_travel = VALUE #( BASE reported-_travel
                                    (
                                      %tky = <fs_travel>-%tky
                                      %state_area = 'INVALID_AGENCY'
                                      %msg = NEW /dmo/cm_flight_messages(
                                                                         textid                = /dmo/cm_flight_messages=>agency_unkown
                                                                         agency_id             = <fs_travel>-%data-AgencyId
                                                                         severity              = if_abap_behv_message=>severity-error
                                                                       )
                                      %element-agencyid = if_abap_behv=>mk-on
                                    )
                                  ).
      ENDIF.

    ENDLOOP.

  ENDMETHOD.

  METHOD validateBeginDate.

    READ ENTITIES OF zi_travel_ay_d IN LOCAL MODE
      ENTITY _Travel
      FIELDS ( BeginDate )
      WITH CORRESPONDING #( keys )
      RESULT DATA(lt_travels).

    LOOP AT lt_travels ASSIGNING FIELD-SYMBOL(<fs_travel>).

      reported-_travel = VALUE #( BASE reported-_travel
                                  (
                                    %tky = <fs_travel>-%tky
                                    %state_area = 'INVALID_BEGINDATE'
                                  )
                                ).

      IF <fs_travel>-%data-BeginDate IS INITIAL.

        failed-_travel = VALUE #( BASE failed-_travel
                                  ( %tky = <fs_travel>-%tky )
                                ).

        reported-_travel = VALUE #( BASE reported-_travel
                                    (
                                      %tky = <fs_travel>-%tky
                                      %state_area = 'INVALID_BEGINDATE'
                                      %msg = NEW /dmo/cm_flight_messages(
                                                                          textid                = /dmo/cm_flight_messages=>enter_begin_date
                                                                          severity              = if_abap_behv_message=>severity-error
                                                                        )
                                      %element-begindate = if_abap_behv=>mk-on
                                    )
                                  ).
      ELSEIF <fs_travel>-BeginDate < cl_abap_context_info=>get_system_date( ).

        failed-_travel = VALUE #( BASE failed-_travel
                                  ( %tky = <fs_travel>-%tky )
                                ).

        reported-_travel = VALUE #( BASE reported-_travel
                                    (
                                      %tky = <fs_travel>-%tky
                                      %state_area = 'INVALID_BEGINDATE'
                                      %msg = NEW /dmo/cm_flight_messages(
                                                                          textid                = /dmo/cm_flight_messages=>enter_begin_date
                                                                          begin_date            = <fs_travel>-%data-BeginDate
                                                                          severity              = if_abap_behv_message=>severity-error
                                                                        )
                                      %element-begindate = if_abap_behv=>mk-on
                                    )
                                  ).


      ENDIF.

    ENDLOOP.


  ENDMETHOD.

  METHOD validateEndDate.

    READ ENTITIES OF zi_travel_ay_d IN LOCAL MODE
      ENTITY _Travel
      FIELDS ( BeginDate EndDate )
      WITH CORRESPONDING #( keys )
      RESULT DATA(lt_travels).

    LOOP AT lt_travels ASSIGNING FIELD-SYMBOL(<fs_travel>).

      reported-_travel = VALUE #( BASE reported-_travel
                                  (
                                    %tky = <fs_travel>-%tky
                                    %state_area = 'INVALID_ENDDATE'
                                  )
                                ).

      IF <fs_travel>-%data-EndDate IS INITIAL.

        failed-_travel = VALUE #( BASE failed-_travel
                                  ( %tky = <fs_travel>-%tky )
                                ).

        reported-_travel = VALUE #( BASE reported-_travel
                                    (
                                      %tky = <fs_travel>-%tky
                                      %state_area = 'INVALID_ENDDATE'
                                      %msg = NEW /dmo/cm_flight_messages(
                                                                          textid                = /dmo/cm_flight_messages=>enter_end_date
                                                                          severity              = if_abap_behv_message=>severity-error
                                                                        )
                                      %element-enddate = if_abap_behv=>mk-on
                                    )
                                  ).
      ELSEIF <fs_travel>-%data-BeginDate > <fs_travel>-%data-EndDate.

        failed-_travel = VALUE #( BASE failed-_travel
                                  ( %tky = <fs_travel>-%tky )
                                ).

        reported-_travel = VALUE #( BASE reported-_travel
                                    (
                                      %tky = <fs_travel>-%tky
                                      %state_area = 'INVALID_ENDDATE'
                                      %msg = NEW /dmo/cm_flight_messages(
                                                                          textid                = /dmo/cm_flight_messages=>enter_end_date
                                                                          end_date              = <fs_travel>-%data-EndDate
                                                                          severity              = if_abap_behv_message=>severity-error
                                                                        )
                                      %element-enddate = if_abap_behv=>mk-on
                                    )
                                  ).

      ENDIF.

    ENDLOOP.

  ENDMETHOD.

  METHOD get_instance_features.

     READ ENTITIES OF zi_travel_ay_d IN LOCAL MODE
       ENTITY _Travel
       FIELDS ( OverallStatus )
       WITH CORRESPONDING #( keys )
       RESULT DATA(lt_travels).

     CHECK lt_travels IS NOT INITIAL.

     LOOP AT lt_travels ASSIGNING FIELD-SYMBOL(<fs_travel>).

*        IF <fs_travel>-%data-OverallStatus = 'A'.
*
*            result = VALUE #( BASE result
*                               (
*                                 %tky = <fs_travel>-%tky
*                                 %features-%action-acceptTravel = if_abap_behv=>fc-o-disabled
*                                 %features-%action-rejectTravel = if_abap_behv=>fc-o-disabled
*                               )
*                            ).
*        ELSEIF <fs_travel>-%data-OverallStatus = 'X'.
*
*            result = VALUE #( BASE result
*                               (
*                                 %tky = <fs_travel>-%tky
*                                 %features-%action-acceptTravel = if_abap_behv=>fc-o-disabled
*                                 %features-%action-rejectTravel = if_abap_behv=>fc-o-disabled
*                               )
*                            ).
*
*        ENDIF.

     ENDLOOP.

  ENDMETHOD.

ENDCLASS.
