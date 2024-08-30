/* When you connect to the Oracle database server, you connect to a container database (CDB) named ROOT. 
* To show the current database, you use the SHOW command:
*/
SHOW con_name;

SELECT * FROM DBA_PDBS;

/* Next, you need to switch to a pluggable database. Noted that during the installation of Oracle, we already 
* created a pluggable database named ADMIN
*/
ALTER SESSION SET CONTAINER = ADMIN;

-- If you execute the show command again, the database now is ADMIN
SHOW con_name;

-- Before creating a new user, you need to change the database to open by executing the following command:
ALTER DATABASE OPEN;

-- List all users that are visible to the current user:
SELECT * FROM all_users;

-- List all users in the Oracle Database:
SELECT * FROM dba_users;

-- Show the information of the current user:
SELECT * FROM user_users;

-- Then, you create a new user for creating the sample database in the pluggable database using the following CREATE USER statement:
CREATE USER subscriptionuser IDENTIFIED BY Subscription123;
/* The above statement created a new user named subscriptionuser with a password specified after the IDENTIFIED BY 
* clause, which is Subscription123 in this case.
*/

-- After that, you grant privileges to the subscriptionuser user by using the following GRANT statement:
GRANT CONNECT, RESOURCE, DBA TO subscriptionuser;

-- As DBA (for example user SYS) we have to execute the following statements to free the way for the subscriptionuser account:
GRANT execute ON utl_http to subscriptionuser;

-- Now we need to Create and assign an Access Control List (ACL) using PL/SQL:
BEGIN
    DBMS_NETWORK_ACL_ADMIN.create_acl(
    acl          => 'local_sx_acl_file.xml', 
    description  => 'A test of the ACL functionality',
    principal    => 'SUBSCRIPTIONUSER',
    is_grant     => TRUE, 
    privilege    => 'connect',
    start_date   => SYSTIMESTAMP,
    end_date     => NULL);
end;
 
begin
  DBMS_NETWORK_ACL_ADMIN.assign_acl (
    acl         => 'local_sx_acl_file.xml',
    host        => '*', 
    lower_port  => NULL,
    upper_port  => NULL);    
end;
/

//Adjust the host URL according to the URL you are calling.
begin
  dbms_network_acl_admin.append_host_ace (
    host       => 'subscription.qa.api.redhat.com', 
    lower_port => 443,
    upper_port => 443,
    ace        => xs$ace_type(privilege_list => xs$name_list('http'),
                              principal_name => 'SUBSCRIPTIONUSER',
                              principal_type => xs_acl.ptype_db)); 
end;
/

SET LINESIZE 150
COLUMN HOST FORMAT A40
COLUMN ACL FORMAT A50

SELECT HOST, LOWER_PORT, UPPER_PORT, ACL
  FROM DBA_NETWORK_ACLS
ORDER BY HOST;


BEGIN
  
  DBMS_NETWORK_ACL_ADMIN.APPEND_WALLET_ACE(
    wallet_path => 'file:/u01/wallet/',
    ace         =>  xs$ace_type(privilege_list => xs$name_list('use_client_certificates'),
                                principal_name => 'SUBSCRIPTIONUSER',
                                principal_type => xs_acl.ptype_db));
END;
/
