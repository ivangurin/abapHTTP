class zcl_http_static definition
  public
  final
  create public .

public section.

  class-methods get
    importing
      !i_url type simple
      !it_headers type zivalues optional
      !it_params type zivalues optional
    returning
      value(e_response) type string
    raising
      zcx_generic .
  class-methods post
    importing
      !i_url type simple
      !it_headers type zivalues optional
      !it_params type zivalues optional
      !i_data type simple optional
    returning
      value(e_response) type string
    raising
      zcx_generic .
protected section.
private section.
ENDCLASS.



CLASS ZCL_HTTP_STATIC IMPLEMENTATION.


method get.

  data lr_client type ref to zcl_http_client.
  create object lr_client
    exporting
      i_url = i_url.

  lr_client->set_method( if_http_request=>co_request_method_get ).

  data ls_header like line of it_headers.
  loop at it_headers into ls_header.

    lr_client->set_header_field(
      i_name  = ls_header-id
      i_value = ls_header-text ).

  endloop.

  data ls_param like line of it_params.
  loop at it_params into ls_param.

    lr_client->r_client->request->set_form_field(
      name  = ls_param-id
      value = ls_param-text ).

  endloop.

  lr_client->send( ).

  lr_client->get_body( ).

  e_response = lr_client->get_body( ).

  lr_client->close( ).

endmethod.


method post.

  data lr_client type ref to zcl_http_client.
  create object lr_client
    exporting
      i_url = i_url.

  lr_client->set_method( if_http_request=>co_request_method_post ).

  data ls_header like line of it_headers.
  loop at it_headers into ls_header.

    lr_client->set_header_field(
      i_name  = ls_header-id
      i_value = ls_header-text ).

  endloop.

  data ls_param like line of it_params.
  loop at it_params into ls_param.

    lr_client->r_client->request->set_form_field(
      name  = ls_param-id
      value = ls_param-text ).

  endloop.

  if i_data is not initial.
    lr_client->set_body( i_data ).
  endif.

  lr_client->send( ).

  lr_client->get_body( ).

  e_response = lr_client->get_body( ).

  lr_client->close( ).

endmethod.
ENDCLASS.
