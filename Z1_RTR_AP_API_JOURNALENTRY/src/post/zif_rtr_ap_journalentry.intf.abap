INTERFACE zif_rtr_ap_journalentry
  PUBLIC.
  TYPES ty_char1 TYPE c LENGTH 1.

  CONSTANTS: BEGIN OF c_action,
               post     TYPE ty_char1 VALUE 'A',
               reverse  TYPE ty_char1 VALUE 'B',
               clearing TYPE ty_char1 VALUE 'C',
             END OF c_action.

ENDINTERFACE.
