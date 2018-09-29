*----------------------------------------------------------------------*
*       CLASS ZCL_HTTP_CLIENT DEFINITION
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
class ZCL_HTTP_CLIENT definition
  public
  final
  create public .

*"* public components of class ZCL_HTTP_CLIENT
*"* do not include other source files here!!!
public section.

  data R_CLIENT type ref to IF_HTTP_CLIENT read-only .
  data TIMEOUT type I read-only .

  methods CONSTRUCTOR
    importing
      !I_URL type SIMPLE optional
      !I_USER type SIMPLE optional
      !I_PASSWORD type SIMPLE optional
    preferred parameter I_URL
    raising
      ZCX_GENERIC .
  methods SET_METHOD
    importing
      !I_METHOD type STRING .
  methods SET_HEADER_FIELD
    importing
      !I_NAME type STRING
      !I_VALUE type STRING .
  methods SET_CONTENT_TYPE
    importing
      !I_CONTENT_TYPE type STRING .
  methods SET_BODY
    importing
      !I_BODY type SIMPLE .
  methods GET_BODY
    returning
      value(E_BODY) type STRING
    raising
      ZCX_GENERIC .
  methods SET_TIMEOUT
    importing
      !I_TIMEOUT type I .
  methods SEND
    importing
      !I_CLOSE type ABAP_BOOL default ABAP_FALSE
    raising
      ZCX_GENERIC .
  methods CLOSE
    raising
      ZCX_GENERIC .
  protected section.
*"* protected components of class ZCL_HTTP_CLIENT
*"* do not include other source files here!!!
  private section.
*"* private components of class ZCL_HTTP_CLIENT
*"* do not include other source files here!!!
ENDCLASS.



CLASS ZCL_HTTP_CLIENT IMPLEMENTATION.


  method close.

    r_client->close(
      exceptions
        http_invalid_state = 1
        others             = 2 ).
    if sy-subrc ne 0.
      zcx_generic=>raise( ).
    endif.

  endmethod.                    "close


  method constructor.

    data l_url type string.
    l_url = i_url.

    data l_url_uc type string.
    l_url_uc = zcl_text_static=>upper_case( l_url ).

    if l_url_uc cs 'HTTPS'.
      data l_ssl_id type ssfapplssl.
      "l_ssl_id = 'ANONYM'.
      l_ssl_id = 'DFAULT'.
    endif.

    cl_http_client=>create_by_url(
      exporting
        url                = l_url
***        proxy_host         = zcl_constants=>value( 'COMMON/HTTP_PROXY_HOST' )
***        proxy_service      = zcl_constants=>value( 'COMMON/HTTP_PROXY_PORT' )
        ssl_id             = l_ssl_id
      importing
        client             = r_client
      exceptions
        argument_not_found = 1
        plugin_not_active  = 2
        internal_error     = 3
        others             = 4 ).
    if sy-subrc ne 0.
      zcx_generic=>raise( ).
    endif.

    set_header_field(
      i_name  = '~request_method'
      i_value = 'GET' ).

    set_header_field(
      i_name  = '~server_protocol'
      i_value = 'HTTP/1.1' ).

***    if i_user is not initial.
***      r_client->authenticate(
***        proxy_authentication = abap_true
***        username             = i_user
***        password             = i_password ).
***    endif.

  endmethod.                    "constructor


  method get_body.

    e_body = r_client->response->get_cdata( ).

  endmethod.                    "get_body


  method send.

    r_client->send(
      exporting
        timeout = timeout
      exceptions
        http_communication_failure = 1
        http_invalid_state         = 2
        http_processing_failed     = 3
        http_invalid_timeout       = 4
        others                     = 5 ).
    if sy-subrc ne 0.
      zcx_generic=>raise( ).
    endif.

    r_client->receive(
      exceptions
        http_communication_failure = 1
        http_invalid_state         = 2
        http_processing_failed     = 3
        others                     = 4 ).
***    if sy-subrc ne 0.
***      zcx_generic=>raise( ).
***    endif.

    data l_code type i.
    data l_reason type string.
    r_client->response->get_status(
      importing
        code   = l_code
        reason = l_reason ).

    if l_code ne '200'.
      zcx_generic=>raise(
        i_text = l_reason ).
    endif.

    if i_close eq abap_true.
      close( ).
    endif.

  endmethod.                    "send


  method set_body.

    data l_body type string.
    l_body = i_body.

    r_client->request->set_cdata( l_body ).

  endmethod.                    "set_body


  method set_content_type.

    r_client->request->set_content_type( i_content_type ).

  endmethod.                    "set_content_type


  method set_header_field.

    r_client->request->set_header_field(
      name  = i_name
      value = i_value ).

  endmethod.                    "set_header_field


  method set_method.

    r_client->request->set_method( i_method ).

  endmethod.                    "set_method


  method set_timeout.

    timeout = i_timeout.

  endmethod.                    "set_timeout
ENDCLASS.
