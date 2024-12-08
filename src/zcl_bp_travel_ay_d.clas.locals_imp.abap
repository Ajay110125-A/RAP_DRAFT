CLASS lhc__Travel DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR _Travel RESULT result.
    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR _travel RESULT result.

ENDCLASS.

CLASS lhc__Travel IMPLEMENTATION.

  METHOD get_instance_authorizations.



  ENDMETHOD.

  METHOD get_global_authorizations.

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
*    ENDIF.


  ENDMETHOD.

ENDCLASS.
