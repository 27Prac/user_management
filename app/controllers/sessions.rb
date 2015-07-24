UserManagement::App.controllers :sessions do
  get :new, :map => "/login" do
    render 'new', :locals => { :error => false ,:notconfirmation => false }
  end

  post :create do
    @user = User.find_by_email(params[:email])
	require 'bcrypt'
	passwordsalt=User::PASSWORD_SALT
	password_hash = BCrypt::Engine.hash_secret(params[:password], passwordsalt)
    if @user && @user.confirmation && @user.password == password_hash
      flash[:notice] = "You have successfully logged in!"
      sign_in(@user)
      redirect '/'
	elsif @user && !@user.confirmation
	  render 'new', :locals => { :notconfirmation => true ,:error => false }
	else
      render 'new', :locals => { :notconfirmation => false , :error => true }
    end
  end

  get :destroy, :map => '/logout' do
    sign_out
    flash[:notice] = "You have successfully logged out."
    redirect '/'
  end
end

