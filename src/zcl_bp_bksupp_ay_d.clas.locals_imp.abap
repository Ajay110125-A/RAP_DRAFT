CLASS lhc__bookingsup DEFINITION INHERITING FROM cl_abap_behavior_handler.

  PRIVATE SECTION.

    METHODS validateSupplimentId FOR VALIDATE ON SAVE
      IMPORTING keys FOR _BookingSup~validateSupplimentId.

ENDCLASS.

CLASS lhc__bookingsup IMPLEMENTATION.

  METHOD validateSupplimentId.

    DATA : lt_suppIds TYPE SORTED TABLE OF /DMO/I_Supplement WITH UNIQUE KEY SupplementID.

    READ ENTITIES OF zi_travel_ay_d IN LOCAL MODE
      ENTITY _BookingSup
      FIELDS ( SupplementId )
      WITH CORRESPONDING #( keys )
      RESULT DATA(lt_bsupps)
      FAILED DATA(lt_failed).

    failed = CORRESPONDING #( DEEP lt_failed ).

    lt_suppids = CORRESPONDING #( lt_bsupps DISCARDING DUPLICATES MAPPING SupplementID = SupplementId EXCEPT * ).

    DELETE lt_suppids WHERE SupplementID IS INITIAL.

    IF lt_suppids IS NOT INITIAL.

      SELECT
        FROM /dmo/supplement
        FIELDS supplement_id
        FOR ALL ENTRIES IN @lt_suppids
        WHERE supplement_id = @lt_suppids-SupplementID
        INTO TABLE @DATA(lt_valid_suppids).

    ENDIF.

    READ ENTITIES OF zi_travel_ay_d IN LOCAL MODE
      ENTITY _BookingSup BY \_Booking
      FROM CORRESPONDING #( lt_bsupps )
      LINK DATA(lt_bookings_linked).

    READ ENTITIES OF zi_travel_ay_d IN LOCAL MODE
      ENTITY _BookingSup BY \_Travel
      FROM CORRESPONDING #( lt_bsupps )
      LINK DATA(lt_travel_linked).

    LOOP AT lt_bsupps ASSIGNING FIELD-SYMBOL(<fs_bsupp>).

      reported-_bookingsup = VALUE #( BASE reported-_bookingsup
                                      (
                                        %tky = <fs_bsupp>-%tky
                                        %state_area = 'INVALID_SUPPLEMENT'
                                      )
                                    ).

      IF <fs_bsupp>-%data-SupplementId IS INITIAL.

        failed-_bookingsup = VALUE #( BASE failed-_bookingsup
                                      ( %tky = <fs_bsupp>-%tky )
                                    ).

        reported-_bookingsup = VALUE #( BASE reported-_bookingsup
                                        (
                                            %tky = <fs_bsupp>-%tky
                                            %msg = NEW /dmo/cm_flight_messages(
                                                                                textid                = /dmo/cm_flight_messages=>enter_supplement_id
                                                                                severity              = if_abap_behv_message=>severity-error
                                                                              )
                                            %element-supplementid = if_abap_behv=>mk-on
                                            %state_area = 'INVALID_SUPPLEMENT'
                                            %path = VALUE #(
                                                             _booking-%tky = lt_bookings_linked[ KEY id source-%tky = <fs_bsupp>-%tky  ]-target-%tky
                                                             _travel-%tky  = lt_travel_linked[ KEY id source-%tky = <fs_bsupp>-%tky ]-target-%tky
                                                           )

                                        )
                                      ).
      ELSEIF NOT line_exists( lt_suppids[ SupplementID = <fs_bsupp>-%data-SupplementId ] ).

        failed-_bookingsup = VALUE #( BASE failed-_bookingsup
                                      ( %tky = <fs_bsupp>-%tky )
                                    ).

        reported-_bookingsup = VALUE #( BASE reported-_bookingsup
                                        (
                                            %tky = <fs_bsupp>-%tky
                                            %msg = NEW /dmo/cm_flight_messages(
                                                                                textid                = /dmo/cm_flight_messages=>enter_supplement_id
                                                                                supplement_id         = <fs_bsupp>-%data-SupplementId
                                                                                severity              = if_abap_behv_message=>severity-error
                                                                              )
                                            %element-supplementid = if_abap_behv=>mk-on
                                            %state_area = 'INVALID_SUPPLEMENT'
                                            %path = VALUE #(
                                                             _booking-%tky = lt_bookings_linked[ KEY id source-%tky = <fs_bsupp>-%tky  ]-target-%tky
                                                             _travel-%tky  = lt_travel_linked[ KEY id source-%tky = <fs_bsupp>-%tky ]-target-%tky
                                                           )

                                        )
                                      ).


      ENDIF.

    ENDLOOP.


  ENDMETHOD.

ENDCLASS.

*"* use this source file for the definition and implementation of
*"* local helper classes, interface definitions and type
*"* declarations
