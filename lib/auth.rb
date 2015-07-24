module Auth
	def get_id_from_auth_token(token)
		return false if token.nil?
		require 'encrypted_strings'
		decrypt=token.decrypt(:symmetric, :algorithm => 'des-ecb', :password => User::SECRET_KEY)
		user_json=JSON.parse(decrypt)
		return user_json['id']
	end
end
