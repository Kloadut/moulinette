# encoding: UTF-8

require 'rubygems'  
require 'test/unit'
require 'highline/import'	# Password prompt
LDAPPWD = ask("Enter LDAP admin password:  ") { |q| q.echo = false }
require 'yunohost/functions'
require 'pp'
 
class TestYunoHostFunctions < Test::Unit::TestCase

  def test_ldap_search
  	result = [{
 		"objectclass" 	=> ["mailAccount", "organizationalRole", "posixAccount", "simpleSecurityObject"],
   		"dn" 	      	=> "cn=admin," + LDAPDOMAIN.chomp
   	  },
  	  {
  	  	"objectclass" 	=> ["sudoRole", "top"],
   	  	"dn"		=> "cn=admin,ou=sudo," + LDAPDOMAIN.chomp
   	  },
  	  {
  	  	"objectclass" 	=> ["groupOfNames", "top"],
   	  	"dn"		=> "cn=admin,ou=groups," + LDAPDOMAIN.chomp
   	  }]
  	assert_equal(result, @@yunoldap.search(LDAPDOMAIN, "(cn=admin)", ["dn", "objectclass"], false))
  end
  
 
  def test_user_add
  	attrs_hash = {
  		"username"	=> "toto",
 		"mail"		=> "toto@tata.net",
 		"lastname"	=> "Tata Titi",
 		"firstname"	=> "Toto",
 		"password"	=> "yayaya"
 	}

 	result = {
 		:dn=>"cn=Toto Tata Titi,ou=users," + LDAPDOMAIN,
 		:attrs 	=> {
 			:objectclass 	=> ["mailAccount", "inetorgperson"],
		   	:uid 		=> "toto",
		   	:givenName   	=> "Toto",
		   	:sn 		=> "Tata Titi",
		   	:mail 		=> "toto@tata.net",
		   	:displayName 	=> "Toto Tata Titi",
		   	:userPassword 	=> "{MD5}odEjpjk2q77oeCPi8a/6mw==",
		   	:cn 		=> "Toto Tata Titi"
		 }
 	}
 	
    user_delete("toto") if @@yunoldap.search(LDAPDOMAIN, "(uid=toto)")
    assert_equal(result, user_add(attrs_hash))
  end
 
  def test_user_delete
    assert_equal(true, user_delete("toto"))
  end
  
end