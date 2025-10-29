CLASS lhc__booking DEFINITION INHERITING FROM cl_abap_behavior_handler.

  PRIVATE SECTION.

    METHODS calTotalPrice FOR DETERMINE ON MODIFY
      IMPORTING keys FOR _Booking~calTotalPrice.

    METHODS setBookingDate FOR DETERMINE ON SAVE
      IMPORTING keys FOR _Booking~setBookingDate.

    METHODS setBookingId FOR DETERMINE ON SAVE
      IMPORTING keys FOR _Booking~setBookingId.

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

ENDCLASS.

*"* use this source file for the definition and implementation of
*"* local helper classes, interface definitions and type
*"* declarations
