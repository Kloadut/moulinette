# encoding: UTF-8

require 'rubygems'
require 'digest/md5'
require 'base64'

def user_add(attrs_hash)

	@@yunoldap.validate({
		attrs_hash["username"]	=> /^[a-z0-9_]+$/,
		attrs_hash["mail"]	=> /^[\w.-]+@[\w.-]+\.[a-zA-Z]{2,6}$/
	})

	@@yunoldap.validate_uniqueness({
		:uid		=> attrs_hash["username"],
		:cn 		=> attrs_hash["firstname"] + " " + attrs_hash["lastname"],
		:mail 		=> attrs_hash["mail"],
		:mailalias 	=> attrs_hash["mail"],
		# :mailforward	=> attrs_hash["mail"],
	})

	dn = "cn=" + attrs_hash["firstname"] + " " + attrs_hash["lastname"] + ",ou=users," + LDAPDOMAIN

	attrs = {
		:objectclass 	=> ["mailAccount", "inetorgperson"],
		:givenName	=> attrs_hash["firstname"],
		:sn 		=> attrs_hash["lastname"],
		:displayName 	=> attrs_hash["firstname"] + " " + attrs_hash["lastname"],
		:cn 		=> attrs_hash["firstname"] + " " + attrs_hash["lastname"],
		:uid 		=> attrs_hash["username"],
		:userPassword 	=> "{MD5}" + Base64.encode64(Digest::MD5.digest(attrs_hash["password"])).chomp,
		:mail 		=> attrs_hash["mail"]
	}

	if @@yunoldap.add(dn, attrs)
		win_msg = SUCCESS + "User successfully created !\n"
		attrs_hash.each do |key, value|
			win_msg << "\n\033[35m\033[1m  " << key.dup.to_s.capitalize! << ": \033[m" << value.to_s
		end
		puts win_msg
		return {:dn => dn, :attrs => attrs}
	end
end

def user_populate(uid)
	user_attrs = ["dn", "cn", "uid", "userPassword", 
		      "objectClass", "mail", "givenName", 
		      "sn", "displayName", "mailalias"]

	if user = @@yunoldap.search("ou=users," + LDAPDOMAIN, "uid=" + uid, user_attrs)
		return user
	else
		puts ERROR + "User '#{uid}' doesn't exists"
		exit ERROR_NOT_FOUND
	end
end

def user_info(uid)
	info_attrs = ["givenName", "sn", "mail", "mailalias", "uid"]
	if user = @@yunoldap.search("ou=users," + LDAPDOMAIN, "uid=" + uid, info_attrs)
		user = user[0]
		user["mail"] = user["mail"].join(", ") if user["mail"].kind_of?(Array)
		if user["mailalias"]
			user["mailalias"] = user["mailalias"].join(", ") if user["mailalias"].kind_of?(Array)
		else
			user["mailalias"] = "none"
		end

		puts "\033[35m\033[1m  Username: \033[m" 	<< user["uid"]
		puts "\033[35m\033[1m  Firstname: \033[m" 	<< user["givenName"]
		puts "\033[35m\033[1m  Lastname: \033[m" 	<< user["sn"]
		puts "\033[35m\033[1m  Mail: \033[m" 		<< user["mail"]
		puts "\033[35m\033[1m  Mail aliases: \033[m" 	<< user["mailalias"]
		return user
	else
		puts ERROR + "User '#{uid}' doesn't exists"
		exit ERROR_NOT_FOUND
	end
end

def user_delete(uids)
	uids.each do |uid|
		if result = @@yunoldap.search("ou=users," + LDAPDOMAIN, "uid=" + uid, "dn")
			puts SUCCESS + "User '#{uid}' successfully deleted !" if @@yunoldap.delete(result[0]["dn"])
			return true
		else
			puts ERROR + "User '#{uid}' doesn't exists"
			exit ERROR_NOT_FOUND
		end
	end
end

def user_filterdelete(filter)
	if result_array = @@yunoldap.search("ou=users," + LDAPDOMAIN, filter.to_s, "dn")
		result_array.each do |result|
			puts SUCCESS + "'#{result["dn"]}' successfully deleted !" if @@yunoldap.delete(result["dn"])
			return true
		end
	else
		puts ERROR + "No user found"
		exit ERROR_NOT_FOUND
	end
end