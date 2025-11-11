CLASS lhc__booking DEFINITION INHERITING FROM cl_abap_behavior_handler.

  PRIVATE SECTION.

    METHODS calTotalPrice FOR DETERMINE ON MODIFY
      IMPORTING keys FOR _Booking~calTotalPrice.

    METHODS setBookingDate FOR DETERMINE ON SAVE
      IMPORTING keys FOR _Booking~setBookingDate.

    METHODS setBookingId FOR DETERMINE ON SAVE
      IMPORTING keys FOR _Booking~setBookingId.
    METHODS validateCustomer FOR VALIDATE ON SAVE
      IMPORTING keys FOR _Booking~validateCustomer.
    METHODS validateCarrierId FOR VALIDATE ON SAVE
      IMPORTING keys FOR _Booking~validateCarrierId.

    METHODS validateConnectionId FOR VALIDATE ON SAVE
      IMPORTING keys FOR _Booking~validateConnectionId.

    METHODS validateFlightDate FOR VALIDATE ON SAVE
      IMPORTING keys FOR _Booking~validateFlightDate.

ENDCLASS.

CLASS lhc__booking IMPLEMENTATION.

  METHOD calTotalPrice.

*** ENTITY _Travel BY \_Booking this statement is very important. This class defined for Bookings which is child of Travel.
*** IN this method we get only BookingUUID, but to reuse the travel internal action reCalTotalPrice we need TravelUUIDs
*** So there this statements says that we are fetching TravelUUIDs using BookingUUIDs which we get by default as importing parameters
    READ ENTITIES OF zi_travel_ay_d IN LOCAL MODE
      ENTITY _Travel BY \_Booking
      FIELDS ( TravelUUID )
      WITH CORRESPONDING #( keys )
      RESULT DATA(lt_travels).

*** Here we are calling Travel internal action in Booking Behavior pool
    MODIFY ENTITIES OF zi_travel_ay_d IN LOCAL MODE
      ENTITY _Travel
      EXECUTE reCalTotalPrice
      FROM CORRESPONDING #( lt_travels ).

  ENDMETHOD.

  METHOD setBookingDate.


*** ENTITY _Travel BY \_Booking this statement is very important. This class defined for Bookings which is child of Travel.
*** IN this method we get only BookingUUID, but to reuse the travel internal action reCalTotalPrice we need TravelUUIDs
*** So there this statements says that we are fetching TravelUUIDs using BookingUUIDs which we get by default as importing parameters

    READ ENTITIES OF zi_travel_ay_d IN LOCAL MODE
      ENTITY _Booking BY \_Travel
      FIELDS ( TravelUUID )
      WITH CORRESPONDING #( keys )
      RESULT DATA(lt_travels).

    CHECK lt_travels IS NOT INITIAL.

    LOOP AT lt_travels ASSIGNING FIELD-SYMBOL(<fs_travel>).

      READ ENTITIES OF zi_travel_ay_d IN LOCAL MODE
        ENTITY _Travel BY \_Booking
        FIELDS ( BookingDate )
        WITH VALUE #( ( %tky = <fs_travel>-%tky ) )
        RESULT DATA(lt_bookings).

      DELETE lt_bookings WHERE BookingDate IS NOT INITIAL.

      IF lt_bookings IS INITIAL.
        RETURN.
      ENDIF.

      MODIFY lt_bookings FROM VALUE #( %data-BookingDate = cl_abap_context_info=>get_system_date(  ) )
                         TRANSPORTING %data-BookingDate
                         WHERE %key-BookingUUID IS NOT INITIAL.

      MODIFY ENTITIES OF zi_travel_ay_d IN LOCAL MODE
       ENTITY _Booking
       UPDATE FIELDS ( BookingDate )
       WITH VALUE #(
                     FOR lwa_booking IN lt_bookings
                     (
                       %tky = lwa_booking-%tky
                       %data-BookingDate = lwa_booking-%data-BookingDate
                     )
                   ).

    ENDLOOP.

  ENDMETHOD.

  METHOD setBookingId.

    DATA : l_max_booking_id TYPE /dmo/booking_id.

    DATA : lt_modifed_bookings TYPE TABLE FOR UPDATE zi_booking_ay_d.

*** Reading TravelUUID for the Booking Instance because the Booking IDs are created based on Travel ID
    READ ENTITIES OF zi_travel_ay_d IN LOCAL MODE
      ENTITY _Booking BY \_Travel
      FIELDS ( TravelUUID )
      WITH CORRESPONDING #( keys )
      RESULT DATA(lt_travels).

    CHECK lt_travels IS NOT INITIAL.

*** Looping on Travel IDs if there are multiple Travel ID are triggered at the same time
    LOOP AT lt_travels ASSIGNING FIELD-SYMBOL(<fs_travel>).

***   Reading all the booking IDs based on particular Travel ID for finding Booking IDs
      READ ENTITIES OF zi_travel_ay_d IN LOCAL MODE
        ENTITY _Travel BY \_Booking
        FIELDS ( BookingId )
        WITH VALUE #( ( %tky = <fs_travel>-%tky ) )
        RESULT DATA(lt_bookings).

      l_max_booking_id = '0000'.

***   Find the last or lasted Booking ID in Use
      LOOP AT lt_bookings ASSIGNING FIELD-SYMBOL(<fs_booking>).

        IF <fs_booking>-%data-BookingId > l_max_booking_id.
          l_max_booking_id = <fs_booking>-%data-BookingId.
        ENDIF.

      ENDLOOP.

***   Creating and assigning new booking for newly created bookings
      LOOP AT lt_bookings ASSIGNING <fs_booking> WHERE BookingId IS INITIAL.

        l_max_booking_id += 1.
        lt_modifed_bookings = VALUE #(
                                        (
                                         %tky = <fs_booking>-%tky
                                         %data-BookingId = l_max_booking_id
                                        )
                                     ).

      ENDLOOP.

    ENDLOOP.

*** Updating the Booking Table with newly created Booking IDs
    MODIFY ENTITIES OF zi_travel_ay_d IN LOCAL MODE
      ENTITY _Booking
      UPDATE FIELDS ( BookingId )
      WITH CORRESPONDING #( lt_modifed_bookings ).



  ENDMETHOD.

  METHOD validateCustomer.

    DATA : lt_customers TYPE SORTED TABLE OF /dmo/customer WITH UNIQUE KEY customer_id.

    READ ENTITIES OF zi_travel_ay_d IN LOCAL MODE
      ENTITY _Booking
      FIELDS ( CustomerId )
      WITH CORRESPONDING #( keys )
      RESULT DATA(lt_bookings).

    READ ENTITIES OF zi_travel_ay_d IN LOCAL MODE
      ENTITY _Booking BY \_Travel
      FROM CORRESPONDING #( lt_bookings )
      LINK DATA(lt_linked_travels).

    lt_customers = CORRESPONDING #( lt_bookings DISCARDING DUPLICATES MAPPING customer_id = CustomerId EXCEPT * ).

    DELETE lt_customers WHERE customer_id IS INITIAL.

    IF lt_customers IS NOT INITIAL.

      SELECT
        FROM /dmo/customer
        FIELDS customer_id
        FOR ALL ENTRIES IN @lt_customers
        WHERE customer_id = @lt_customers-customer_id
        INTO TABLE @DATA(lt_valid_customers).

    ENDIF.

    LOOP AT lt_bookings ASSIGNING FIELD-SYMBOL(<fs_booking>).

      reported-_booking = VALUE #( BASE reported-_booking
                                   (
                                      %tky = <fs_booking>-%tky
                                      %state_area = 'INVALID_CUSTOMER'
                                   )
                                 ).

      IF <fs_booking>-%data-CustomerId IS INITIAL.

        failed-_booking = VALUE #( BASE failed-_booking
                                   ( %tky = <fs_booking>-%tky )
                                 ).

        reported-_booking = VALUE #( BASE reported-_booking
                                     (
                                        %tky = <fs_booking>-%tky
                                        %state_area = 'INVALID_CUSTOMER'
                                        %msg = NEW /dmo/cm_flight_messages(
                                                                            textid                = /dmo/cm_flight_messages=>enter_customer_id
                                                                            severity              = if_abap_behv_message=>severity-error
                                                                          )
                                        %path = VALUE #(
                                                         _travel-%tky = lt_linked_travels[ KEY id source-%tky = <fs_booking>-%tky ]-target-%tky
                                                       )
                                        %element-customerid = if_abap_behv=>mk-on
                                     )
                                   ).
      ELSEIF NOT line_exists( lt_customers[ customer_id = <fs_booking>-%data-CustomerId ] ).

        failed-_booking = VALUE #( BASE failed-_booking
                                    ( %tky = <fs_booking>-%tky )
                                 ).

        reported-_booking = VALUE #( BASE reported-_booking
                                     (
                                        %tky = <fs_booking>-%tky
                                        %state_area = 'INVALID_CUSTOMER'
                                        %msg = NEW /dmo/cm_flight_messages(
                                                                            textid                = /dmo/cm_flight_messages=>customer_unkown
                                                                            customer_id           = <fs_booking>-%data-CustomerId
                                                                            severity              = if_abap_behv_message=>severity-error
                                                                          )
                                        %element-customerid = if_abap_behv=>mk-on
                                     )
                                   ).

      ENDIF.

    ENDLOOP.



  ENDMETHOD.

  METHOD validateCarrierId.

    DATA : lt_carrier_id TYPE SORTED TABLE OF /dmo/carrier WITH UNIQUE KEY carrier_id.

    READ ENTITIES OF zi_travel_ay_d IN LOCAL MODE
      ENTITY _Booking
      FIELDS ( CarrierId )
      WITH CORRESPONDING #( keys )
      RESULT DATA(lt_bookings).

    lt_carrier_id = CORRESPONDING #( lt_bookings DISCARDING DUPLICATES MAPPING carrier_id = CarrierId EXCEPT * ).

    DELETE lt_carrier_id WHERE carrier_id IS INITIAL.

    READ ENTITIES OF zi_travel_ay_d IN LOCAL MODE
      ENTITY _Booking BY \_Travel
      FROM CORRESPONDING #( lt_bookings )
      LINK DATA(lt_linked_travels).

    IF lt_carrier_id IS NOT INITIAL.

      SELECT
        FROM /dmo/carrier
        FIELDS carrier_id
        FOR ALL ENTRIES IN @lt_carrier_id
        WHERE carrier_id = @lt_carrier_id-carrier_id
        INTO TABLE @DATA(lt_valid_carrierid).

    ENDIF.

    LOOP AT lt_bookings ASSIGNING FIELD-SYMBOL(<fs_booking>).

      reported-_booking = VALUE #( BASE reported-_booking
                                   (
                                     %tky = <fs_booking>-%tky
                                     %state_area = 'INVALID_CARRIER_ID'
                                   )
                                 ).

      IF <fs_booking>-%data-CarrierId IS INITIAL.

        failed-_booking = VALUE #( BASE failed-_booking
                                   ( %tky = <fs_booking>-%tky )
                                 ).

        reported-_booking = VALUE #( BASE reported-_booking
                                     (
                                        %tky = <fs_booking>-%tky
                                        %msg = NEW /dmo/cm_flight_messages(
                                                                            textid                = /dmo/cm_flight_messages=>enter_airline_id
                                                                            severity              = if_abap_behv_message=>severity-error
                                                                          )
                                        %element-carrierid = if_abap_behv=>mk-on
                                        %path = VALUE #( _travel-%tky = lt_linked_travels[ KEY id
                                                                                           source-%tky = <fs_booking>-%tky
                                                                                         ]-target-%tky
                                                       )
                                        %state_area = 'INVALID_CARRIER_ID'
                                     )
                                   ).

      ELSEIF NOT line_exists( lt_carrier_id[ carrier_id = <fs_booking>-%data-CarrierId ] ).

        failed-_booking = VALUE #( BASE failed-_booking
                                   ( %tky = <fs_booking>-%tky )
                                 ).

        reported-_booking = VALUE #( BASE reported-_booking
                                     (
                                        %tky = <fs_booking>-%tky
                                        %msg = NEW /dmo/cm_flight_messages(
                                                                            textid                = /dmo/cm_flight_messages=>enter_airline_id
                                                                            carrier_id            = <fs_booking>-%data-CarrierId
                                                                            severity              = if_abap_behv_message=>severity-error
                                                                          )
                                        %element-carrierid = if_abap_behv=>mk-on
                                        %path = VALUE #( _travel-%tky = lt_linked_travels[ KEY id
                                                                                           source-%tky = <fs_booking>-%tky
                                                                                         ]-target-%tky
                                                       )
                                        %state_area = 'INVALID_CARRIER_ID'
                                     )
                                   ).


      ENDIF.

    ENDLOOP.

  ENDMETHOD.

  METHOD validateConnectionId.

    DATA : lt_connections TYPE SORTED TABLE OF /dmo/connection WITH UNIQUE KEY carrier_id connection_id.

    READ ENTITIES OF zi_travel_ay_d IN LOCAL MODE
      ENTITY _Booking
      FIELDS ( CarrierId ConnectionId )
      WITH CORRESPONDING #( keys )
      RESULT DATA(lt_bookings).

    lt_connections = CORRESPONDING #( lt_bookings DISCARDING DUPLICATES MAPPING carrier_id = CarrierId connection_id = ConnectionId EXCEPT * ).

    DELETE lt_connections WHERE carrier_id IS INITIAL OR connection_id IS INITIAL.

    IF lt_connections IS NOT INITIAL.

      SELECT
        FROM /dmo/connection
        FIELDS carrier_id, connection_id
        FOR ALL ENTRIES IN @lt_connections
        WHERE carrier_id = @lt_connections-carrier_id
        AND   connection_id = @lt_connections-connection_id
        INTO TABLE @DATA(lt_valid_connections).

    ENDIF.

    READ ENTITIES OF zi_travel_ay_d IN LOCAL MODE
      ENTITY _Booking BY \_Travel
      FROM CORRESPONDING #( lt_bookings )
      LINK DATA(lt_linked_travels).

    LOOP AT lt_bookings ASSIGNING FIELD-SYMBOL(<fs_booking>).

      reported-_booking = VALUE #( BASE reported-_booking
                                   (
                                      %tky = <fs_booking>-%tky
                                      %state_area = 'INVALID_CONNECTIONS'
                                   )
                                 ).

      IF <fs_booking>-%data-CarrierId IS INITIAL.

        failed-_booking = VALUE #( BASE failed-_booking
                                   ( %tky = <fs_booking>-%tky )
                                 ).

        reported-_booking = VALUE #( BASE reported-_booking
                                     (
                                        %tky = <fs_booking>-%tky
                                        %msg = NEW /dmo/cm_flight_messages(
                                                                            textid                = /dmo/cm_flight_messages=>enter_airline_id
                                                                            severity              = if_abap_behv_message=>severity-error
                                                                          )
                                        %element-carrierid = if_abap_behv=>mk-on
                                        %path = VALUE #( _travel-%tky = lt_linked_travels[ KEY id
                                                                                           source-%tky = <fs_booking>-%tky
                                                                                         ]-target-%tky
                                                       )
                                        %state_area = 'INVALID_CONNECTIONS'
                                     )
                                   ).

      ELSEIF <fs_booking>-%data-ConnectionId IS INITIAL.

        failed-_booking = VALUE #( BASE failed-_booking
                                   ( %tky = <fs_booking>-%tky )
                                 ).

        reported-_booking = VALUE #( BASE reported-_booking
                                     (
                                        %tky = <fs_booking>-%tky
                                        %msg = NEW /dmo/cm_flight_messages(
                                                                            textid                = /dmo/cm_flight_messages=>enter_connection_id
                                                                            severity              = if_abap_behv_message=>severity-error
                                                                          )
                                        %element-connectionid = if_abap_behv=>mk-on
                                        %path = VALUE #( _travel-%tky = lt_linked_travels[ KEY id
                                                                                           source-%tky = <fs_booking>-%tky
                                                                                         ]-target-%tky
                                                       )
                                        %state_area = 'INVALID_CONNECTIONS'
                                     )
                                   ).
      ELSEIF NOT line_exists( lt_connections[ carrier_id = <fs_booking>-%data-CarrierId connection_id = <fs_booking>-%data-ConnectionId ] ).

        failed-_booking = VALUE #( BASE failed-_booking
                                   ( %tky = <fs_booking>-%tky )
                                 ).

        reported-_booking = VALUE #( BASE reported-_booking
                                     (
                                        %tky = <fs_booking>-%tky
                                        %msg = NEW /dmo/cm_flight_messages(
                                                                            textid                = /dmo/cm_flight_messages=>enter_connection_id
                                                                            carrier_id            = <fs_booking>-%data-CarrierId
                                                                            connection_id         = <fs_booking>-%data-ConnectionId
                                                                            severity              = if_abap_behv_message=>severity-error
                                                                          )
                                        %element-carrierid    = if_abap_behv=>mk-on
                                        %element-connectionid = if_abap_behv=>mk-on
                                        %path = VALUE #( _travel-%tky = lt_linked_travels[ KEY id
                                                                                           source-%tky = <fs_booking>-%tky
                                                                                         ]-target-%tky
                                                       )
                                        %state_area = 'INVALID_CONNECTIONS'
                                     )
                                   ).

      ENDIF.

    ENDLOOP.



  ENDMETHOD.

  METHOD validateFlightDate.

    READ ENTITIES OF zi_travel_ay_d IN LOCAL MODE
      ENTITY _Booking
      FIELDS ( FlightDate )
      WITH CORRESPONDING #( keys )
      RESULT DATA(lt_bookings).

    READ ENTITIES OF zi_travel_ay_d IN LOCAL MODE
      ENTITY _Booking BY \_Travel
      FROM CORRESPONDING #( lt_bookings )
      LINK DATA(lt_linked_travels).

    LOOP AT lt_bookings ASSIGNING FIELD-SYMBOL(<fs_booking>).

        reported-_booking = VALUE #( BASE reported-_booking
                                     (
                                       %tky = <fs_booking>-%tky
                                       %state_area = 'INVALID_FLIGHT_DATE'
                                     )
                                   ).

*        IF

    ENDLOOP.


  ENDMETHOD.

ENDCLASS.

*"* use this source file for the definition and implementation of
*"* local helper classes, interface definitions and type
*"* declarations
