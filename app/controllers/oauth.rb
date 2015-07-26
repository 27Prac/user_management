UserManagement::App.controllers :oauth do

	# get '/oauth/apps/new' do
	# 	@client = Songkick::OAuth2::Model::Client.new
	# 	erb :new_client
	# end

	get :new, :map => "/oauth/apps/new" do
		@client = Songkick::OAuth2::Model::Client.new
		render 'new_client'
	end

	post :appnew , :map => '/oauth/apps' do
		@client = Songkick::OAuth2::Model::Client.new(params)
		if @client.save
			session[:client_secret] = @client.client_secret
			redirect("/oauth/apps/#{@client.id}")
		else
			render 'new_client'
		end
	end

	get :appid , :map =>  '/oauth/apps/:id' do
		@client = Songkick::OAuth2::Model::Client.find_by_id(params[:id])
		@client_secret = session[:client_secret]
		render 'show_client'
	end

	[:get, :post].each do |method|
		__send__ method ,:authconnect , :map => 'v1.0/oauth/authorize' do
			#@user = User.find_by_id(1)
			@user =nil
			@oauth2 = Songkick::OAuth2::Provider.parse(@user, env)

			if @oauth2.redirect?
				redirect @oauth2.redirect_uri, @oauth2.response_status
			end

			headers @oauth2.response_headers
			status  @oauth2.response_status

			if body = @oauth2.response_body
				body
			elsif @oauth2.valid?
				render 'login'
			else
				render 'error'
			end
		end
	end

	post :login , :map =>  '/loginauth' do
		@user = User.find_by_email(params[:email])
		if @user &&  !@user.confirmation
			raise NoConfirmationYetError, { user: "Please confirm by clicking on confirmation link"}
		elsif @user && @user.authenticateuser(params[:password])
			@oauth2 = Songkick::OAuth2::Provider.parse(@user, env)
			session[:user_id] = @user.id
			render 'authorize'
		else
			raise InvalidCredentialsError, { user: "Invalid Credentials"}
		end
	end

	post :allow , :map =>  '/oauth/allow' do
		@user = User.find_by_id(session[:user_id])
		@auth = Songkick::OAuth2::Provider::Authorization.new(@user, params)
		if params['allow'] == '1'
			@auth.grant_access!
		else
			@auth.deny_access!
		end
		#redirect @auth.redirect_uri, @auth.response_status
		access_token=@auth.redirect_uri.split('#')[1].split('=')[1]
		#redirect url(:sessions, :create,:Authorization => access_token)
		redirect url("http://localhost:3001/sessions/create?Authorization=#{access_token}",:Authorization => access_token)
	end
end
