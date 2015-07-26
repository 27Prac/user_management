require 'rubygems'
require 'sinatra'
require 'json'

UserManagement::App.controllers :users do

   before  :updateuser ,:read  do
	   authorization = Songkick::OAuth2::Provider.access_token(:implicit, [], request.env)
	   headers authorization.response_headers
	   status  authorization.response_status
	   if authorization.valid?
		   id=authorization.owner.id
		   @user = User.find_by_id(id)
	   else
		  raise UnAuthorizedAccessErorr,  { user: "Not able to authrize access token" }
	   end
   end

   # Rest APIs
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

  post :new , :map => 'v1.0/users' do
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
		  raise NoUserCreateException ,  { user: "No user created: Email already exists . Please choose a differenct email" }
	  end
  end

   put :updateuser, :map => 'v1.0/users/' do
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

   get :read, :map => 'v1.0/users/' do
	   raise ResourceNotFoundError ,  { user: "user does not exist" } if @user.nil?
	   @view_obj = {base: "localhost:3000",_id: @user.id,email: @user.email ,name: @user.name}
	   content_type :json
	   error 200, "while (1) {}\n" + @view_obj.to_json
   end

   delete :delete , :map => 'v1.0/users/' do
	   raise PermissionError ,  { user: "user cannot be deleted for now" }
   end

end

