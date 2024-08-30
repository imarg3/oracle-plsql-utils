create or replace PROCEDURE invoke_api_call AS

    l_http_request  utl_http.req;
    l_http_response utl_http.resp;
    l_url           VARCHAR2(200) := 'https://google.com/'
    ;
    l_text          VARCHAR2(2000);
    name            VARCHAR2(256);
    value           VARCHAR2(1024);
BEGIN
    -- Prepare the HTTP request- Prepare the HTTP request
    utl_http.set_wallet('file:/u01/wallet/', 'OracleWallet123');
    l_http_request := utl_http.begin_request(l_url, 'GET', 'HTTP/1.1');
    utl_http.set_header(l_http_request, 'user-agent', 'mozilla/4.0');
    
    -- Get the HTTP response
    l_http_response := utl_http.get_response(l_http_request);
    FOR i IN 1..utl_http.get_header_count(l_http_response) LOOP
        utl_http.get_header(l_http_response, i, name, value);
        dbms_output.put_line(name
                             || ': '
                             || value);
    END LOOP;
    
    -- Read the response
    BEGIN
        LOOP
            utl_http.read_text(l_http_response, l_text, 32766);
            dbms_output.put_line('Text: ' || l_text); -- Display the response
        END LOOP;
    EXCEPTION
        WHEN utl_http.end_of_body THEN
            utl_http.end_response(l_http_response);
        WHEN OTHERS THEN
            utl_http.end_response(l_http_response);
            dbms_output.put_line('Error: ' || sqlerrm);
    END;

END invoke_api_call;
