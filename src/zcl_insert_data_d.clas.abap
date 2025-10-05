CLASS zcl_insert_data_d DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_oo_adt_classrun .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_INSERT_DATA_D IMPLEMENTATION.


  METHOD if_oo_adt_classrun~main.

    INSERT zaj_travel_d FROM ( SELECT * FROM /dmo/a_travel_d ).

    INSERT zaj_booking_d FROM ( SELECT * FROM /dmo/a_booking_d ).

    INSERT zaj_bksupp_d FROM ( SELECT  * FROM /dmo/a_bksuppl_d ).

    COMMIT WORK.

    out->write( 'Data Inserted in to Tables' ).

  ENDMETHOD.
ENDCLASS.
