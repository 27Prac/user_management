UserManagement::App.controllers :page do
  get :home, :map => "/" do
    render 'home'
  end
end

