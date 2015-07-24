require 'rubygems'
require 'sinatra'
require 'json'

UserManagement::App.controllers :users do
   before :edit, :update  do
     redirect('/login') unless signed_in?
     @user = User.find_by_id(params[:id])
     redirect('/login') unless current_user?(@user)
   end

   before  :updateuser ,:read  do
	   id=User.get_id(request.env['HTTP_AUTHORIZATION'])
	   @user = User.find_by_id(id)
   end

  get :new, :map => "/register" do
    @user = User.new
    render 'new'
  end

  post :create do
   @user = User.new(params[:user])
   if @user.save
	   flash[:notice] = "You have been registered. Please confirm with the mail we've send you recently."
	   redirect('/')
   else
	   render 'new'
   end
  end

  get :confirm, :map => "/confirm/:id/:code" do
    @user = User.find_by_id(params[:id])

    if @user && @user.authenticate(params[:code])
      flash[:notice] = "You have been confirmed. Please confirm with the mail we've send you recently."
      render 'confirm'
    else
      flash[:error] = "Confirmed code is wrong."
      redirect('/')
    end
  end

  get :edit, :map => '/users/:id/edit' do
    @user = User.find_by_id(params[:id])
    render 'edit'
  end

  put :update, :map => '/users/:id' do
    @user = User.find_by_id(params[:id])

    unless @user
      flash[:error] = "User is not registered in our platform."
      render 'edit'
    end

    if @user.update_attributes(params[:user])
      flash[:notice] = "You have updated your profile."
      render 'edit'
    else
      flash[:error] = "Your profile was not updated."
      render 'edit'
    end
  end

   #Pure Rest APIs
  post :new , :map => 'users' do
	  @body = json_body_from_req
	  raise InputValidationError, { body: "must be valid JSON"} unless @body && @body.is_a?(Hash)
	  @name=@body["name"]
	  @email=@body["email"]
	  @password=@body["password"]
	  @user = User.new(:name => @name, :email => @email,:password => @password )
      if @user.save
		  READ_URL="localhost:3000/users/#{@user.id}"
		  response['Location'] = READ_URL
		  204
	  else
		  raise NoUserCreateException ,  { user: "No user created" }
	  end
  end

  post :token , :map => 'users/token' do
	   @body = json_body_from_req
	   raise InputValidationError, { body: "must be valid JSON"} unless @body && @body.is_a?(Hash)
	   @email=@body["email"]
	   @password=@body["password"]
	   @user = User.find_by_email(@email)
	   TOKEN=nil
	   if @user &&  !@user.confirmation
		   raise NoConfirmationYetError, { user: "Please confirm by clicking on confirmation link"}
	   end
	   if @user && @user.authenticateuser(@password)
		    TOKEN= @user.generate_auth_token()
	   else
		   raise InvalidCredentialsError, { user: "Invalid Credentials"}
	   end
	   response['Authorization'] = TOKEN
	   202
  end

   put :updateuser, :map => '/user/' do
	   @body = json_body_from_req
	   raise InputValidationError, { body: "must be valid JSON"} unless @body && @body.is_a?(Hash)
	   @name=@body["name"]
	   @email=@body["email"]
	   param={:name => @name, :email => @email}
	   if @user.update_attributes(param)
		   content_type :json
		   201
	   end
   end

   get :read, :map => 'users/' do
	   raise ResourceNotFoundError ,  { user: "user does not exist" } if @user.nil?
	   @view_obj = {base: "localhost:3000",_id: @user.id,email: @user.email ,name: @user.name}
	   content_type :json
	   error 200, "while (1) {}\n" + @view_obj.to_json
   end

   delete :delete , :map => 'users/' do
	   raise PermissionError ,  { user: "user cannot be deleted for now" }
   end

end

