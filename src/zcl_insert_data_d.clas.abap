CLASS zcl_insert_data_d DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_oo_adt_classrun .
    METHODS ausp_validation.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_insert_data_d IMPLEMENTATION.


  METHOD if_oo_adt_classrun~main.

    INSERT zaj_travel_d FROM ( SELECT * FROM /dmo/a_travel_d ).

    INSERT zaj_booking_d FROM ( SELECT * FROM /dmo/a_booking_d ).

    INSERT zaj_bksupp_d FROM ( SELECT  * FROM /dmo/a_bksuppl_d ).

    COMMIT WORK.

    out->write( 'Data Inserted in to Tables' ).

  ENDMETHOD.

  METHOD ausp_validation.
**&---------------------------------------------------------------------*
**& Class ZCL_GGL_OPS_BOM_COCKPIT
**&---------------------------------------------------------------------*
**  Modification Log:                                                   *
**&--------------------------------------------------------------------**
** MOD|  Date   | Programmer |  CTS  |   Description ( CRF/TPR Name)    *
**                                                                      *
**&--------------------------------------------------------------------**
**  1  04/12/2020  09283507   DM2K902087   To trigger PCD Validation    *
** 002 20/03/2021  09283508   DM2K902249   R4C-Rounding changes
** 003 12/04/2021  09268558   DM2K902286   R4C-Drop2
**&--------------------------------------------------------------------**
*    DATA : lr_matnr  TYPE RANGE OF matnr,
*           lr_mat    TYPE RANGE OF matnr,
*           lv_atinn  TYPE atinn,
*           lr_region TYPE RANGE OF zggl_ops_del_region,
*           lt_itm    TYPE zgglops_tty_item.
** Begin of change MOD-002 ++
*    DATA : lv_cnt TYPE sy-index,
*           lt_kt  TYPE zgglops_tty_item,
*           lt_scm TYPE TABLE OF dd07v.
** End of change MOD-002 ++
*    CLEAR : et_item,et_ausp,ev_flag.
*    DATA(ls_header) = is_header.
**    To fetch Region
*    SELECT low
*      FROM tvarvc
*      INTO TABLE @DATA(lt_region)
*      WHERE name = @c_zggl_ops_region.
*    IF sy-subrc = 0.
*      SORT lt_region BY low.
*    ENDIF.
*    lr_region = VALUE #( FOR ls_region IN lt_region ( sign = c_i
*                                                option = c_eq
*                                                low = ls_region-low ) ).
*    SELECT *
*      FROM zggltops_bcitem
*      INTO TABLE @DATA(lt_item)
*      WHERE poi_number = @is_header-poi_number ORDER BY PRIMARY KEY.
*    IF sy-subrc = 0.
** Begin of change MOD-002 ++
*      CALL FUNCTION 'GET_DOMAIN_VALUES'
*        EXPORTING
*          domname         = c_scm_model_domain
*          text            = c_x
*        TABLES
*          values_tab      = lt_scm
*        EXCEPTIONS
*          no_values_found = 1
*          OTHERS          = 2.
*      IF sy-subrc = 0.
*        SORT lt_scm BY ddtext.
*      ENDIF.
** End of change MOD-002 ++
*      CLEAR: lv_cnt.  "MOD-002 ++
*      LOOP AT lt_item ASSIGNING FIELD-SYMBOL(<fs_item>)
*                                WHERE bom_class = c_kt
*                                   OR bom_class = c_sa
*                                   OR bom_class = c_sf
*                                   OR bom_class = c_bb
*                                   OR bom_class = c_sb
*                                   OR bom_class = c_lf.
** Begin of change MOD-002 ++
*        DATA(ls_scm) = VALUE #( lt_scm[ ddtext = <fs_item>-scm_model ]
*                       OPTIONAL ).
*        IF ls_scm IS NOT INITIAL.
*          <fs_item>-scm_model = ls_scm-domvalue_l.
*        ENDIF.
*        IF <fs_item>-bom_class = c_kt.
*          CLEAR: lv_cnt.
*          DATA(ls_item) = <fs_item>.
*        ELSE.
*          IF ls_item-expl_lev < <fs_item>-expl_lev.
*            <fs_item>-header_seq = ls_item-seq_number.
*          ELSE.
*            CLEAR: <fs_item>-header_seq.
*            DATA(lv_btl) = abap_true.
*          ENDIF.
*        ENDIF.
*        lv_cnt = lv_cnt + 1.
*        IF lv_cnt = 2.
*          ls_item-scm_model = <fs_item>-scm_model.
*          ls_item-liquid_dry = <fs_item>-liquid_dry.
*          CASE ls_item-scm_model.
*            WHEN c_mak.
*              IF ls_item-liquid_dry = c_yes.
*                ls_item-expl_lev_ind = |{ 1 }|.
*              ELSE.
*                ls_item-expl_lev_ind = |{ 2 }|.
*              ENDIF.
*            WHEN c_vde OR c_vtp.
*              IF ls_item-liquid_dry = c_yes.
*                ls_item-expl_lev_ind = |{ 3 }|.
*              ELSE.
*                ls_item-expl_lev_ind = |{ 4 }|.
*              ENDIF.
*            WHEN c_btl.
*              IF ls_item-liquid_dry = c_yes.
*                ls_item-expl_lev_ind = |{ 5 }|.
*              ELSE.
*                ls_item-expl_lev_ind = |{ 6 }|.
*              ENDIF.
*            WHEN OTHERS.
*              IF ls_item-liquid_dry = c_yes.
*                ls_item-expl_lev_ind = |{ 7 }|.
*              ELSE.
*                ls_item-expl_lev_ind = |{ 8 }|.
*              ENDIF.
*          ENDCASE.
*          APPEND ls_item TO lt_kt.
*        ENDIF.
** End of change MOD-002 ++
*        APPEND <fs_item> TO et_item.
*        IF <fs_item>-bom_class = c_kt OR
*<fs_item>-bom_class = c_sa OR
*<fs_item>-bom_class = c_lf.
*          APPEND <fs_item> TO lt_itm.
*        ENDIF.
*      ENDLOOP.
*    ENDIF.
*    IF ls_header-region IN lr_region.
** to populate PCNA/QTG_CODE value
*      CALL FUNCTION 'CONVERSION_EXIT_ATINN_INPUT'
*        EXPORTING
*          input  = c_pcna_qtg "'Z_PGCS_CUSTMATNUM'
*        IMPORTING
*          output = lv_atinn.
** validate the KT, SA and LF based on the Material SKU for R6/QTG fields
*      lr_matnr = VALUE #( FOR ls_value IN lt_itm ( sign   = c_i
*                                                   option = c_eq
*                                                   low    =
*                                                   ls_value-matnr ) ).
*      SORT lr_matnr BY low.
*      DELETE ADJACENT DUPLICATES FROM lr_matnr COMPARING low.
*      DELETE lr_matnr WHERE low IS INITIAL.
*
*      SELECT objek
*        FROM ausp
*        INTO TABLE @DATA(lt_ausp)
*        WHERE objek IN @lr_matnr
*        AND atinn = @lv_atinn.
*      IF sy-subrc NE 0.
*        ev_flag = abap_true.
*      ELSE.
*        DESCRIBE TABLE lt_ausp LINES DATA(lv_ausp).
*        DESCRIBE TABLE lr_matnr LINES DATA(lv_matnr).
*        IF lv_ausp NE lv_matnr.
*          ev_flag = abap_true.
*        ENDIF.
*      ENDIF.
** fetch Values to be populated in R6/QTG field for interface trigger
*      lr_mat = VALUE #( FOR ls_mat IN et_item ( sign   = c_i
*                                                option = c_eq
*                                                low  = ls_mat-matnr ) ).
*      SORT lr_mat BY low.
*      DELETE ADJACENT DUPLICATES FROM lr_mat COMPARING low.
*      SELECT *
*        FROM ausp
*        INTO TABLE et_ausp
*        WHERE objek IN lr_mat
*        AND atinn = lv_atinn.
*      IF sy-subrc NE 0.
*        SORT et_ausp BY objek.
*      ENDIF.
*    ENDIF.
** Begin of change MOD-002 ++
*    DELETE et_item WHERE bom_class = c_kt.
*    IF lv_btl = abap_true.
*      CLEAR: ls_item.
*      ls_item-seq_number = 0.
*      ls_item-expl_lev_ind = |{ 9 }|.
*      APPEND ls_item TO lt_kt.
*    ENDIF.
*    SORT lt_kt BY expl_lev_ind seq_number.
*    CLEAR: lv_cnt.
*    LOOP AT lt_kt ASSIGNING FIELD-SYMBOL(<fs_temp>).
*      lv_cnt = lv_cnt + 1.
*      <fs_temp>-expl_lev_ind = |{ lv_cnt }|.
*      LOOP AT et_item ASSIGNING <fs_item> WHERE header_seq = <fs_temp>-seq_number.
*        CASE <fs_item>-scm_model.
*          WHEN c_mak.
*            IF <fs_item>-liquid_dry = c_yes.
*              IF <fs_item>-manually_added = c_yes.
*                <fs_item>-expl_lev_ind = |{ lv_cnt }{ 0 }|.
*              ELSE.
*                <fs_item>-expl_lev_ind = |{ lv_cnt }{ 2 }|.
*              ENDIF.
*            ELSE.
*              <fs_item>-expl_lev_ind = |{ lv_cnt }{ 1 }|.
*            ENDIF.
*          WHEN c_vde OR c_vtp.
*            IF <fs_item>-liquid_dry = c_yes.
*              <fs_item>-expl_lev_ind = |{ lv_cnt }{ 3 }|.
*            ELSE.
*              <fs_item>-expl_lev_ind = |{ lv_cnt }{ 4 }|.
*            ENDIF.
*          WHEN c_btl.
*            IF <fs_item>-liquid_dry = c_yes.
*              <fs_item>-expl_lev_ind = |{ lv_cnt }{ 5 }|.
*            ELSE.
*              <fs_item>-expl_lev_ind = |{ lv_cnt }{ 6 }|.
*            ENDIF.
*          WHEN OTHERS.
*            IF <fs_item>-liquid_dry = c_yes.
*              <fs_item>-expl_lev_ind = |{ lv_cnt }{ 7 }|.
*            ELSE.
*              <fs_item>-expl_lev_ind = |{ lv_cnt }{ 8 }|.
*            ENDIF.
*        ENDCASE.
*      ENDLOOP.
*    ENDLOOP.
*    DELETE lt_kt WHERE seq_number = 0.
*    APPEND LINES OF lt_kt TO et_item.
** Begin of Change MOD-003++
*    CLEAR: lt_itm.
*    SORT et_item BY bom_class manually_added.
*    LOOP AT et_item ASSIGNING <fs_item> WHERE bom_class = c_sb
*      AND manually_added = c_yes.
*      DATA(lt_sbcomp) = lt_item.
*      DELETE lt_sbcomp WHERE header_seq NE <fs_item>-seq_number.
*      IF lt_sbcomp IS NOT INITIAL.
*        SORT lt_sbcomp BY seq_number.
*        LOOP AT lt_sbcomp ASSIGNING FIELD-SYMBOL(<fs_sort>).
*          <fs_sort>-expl_lev_ind = <fs_item>-expl_lev_ind.
*          <fs_sort>-perqty_kg = ( <fs_sort>-fss_1unitkg * <fs_item>-units_pkg ).
*          <fs_sort>-perqty_l = ( <fs_sort>-fss_1unitltr * <fs_item>-units_pkg ).
*          <fs_sort>-perqty_lb = ( <fs_sort>-fss_1unitlb * <fs_item>-units_pkg ).
*          <fs_sort>-perqty_gal = ( <fs_sort>-fss_1unitgal * <fs_item>-units_pkg ).
*        ENDLOOP.
*        APPEND LINES OF lt_sbcomp TO lt_itm.
*      ENDIF.
*      CLEAR: lt_sbcomp.
*    ENDLOOP.
*    IF lt_itm IS NOT INITIAL.
*      APPEND LINES OF lt_itm TO et_item.
*    ENDIF.
*    SORT et_item BY expl_lev_ind seq_number.
*    LOOP AT et_item ASSIGNING <fs_sort>.
*      <fs_sort>-seq_number =  sy-tabix.
*    ENDLOOP.
** End of change MOD-003 ++
** End of change MOD-002 ++
*    CLEAR: lt_item,lv_atinn,lr_matnr,lr_region,lt_region,lt_itm,lt_ausp,
*           lr_mat,lv_matnr,lv_ausp.
  ENDMETHOD.
ENDCLASS.
