Rails.application.routes.draw do
  get 'home/index'
  # Resources
  resources "sessions"
  resources "users"
  resources "dice"
  resources "home" #home page of app
  #resources "logged_movies" #tab for table of logged movies
  resources :logged_movies, param: :tmdb_id
  root to: 'home#index'

  get 'domestic_box_office/filter', to: 'domestic_box_office#filter', as: 'filter_domestic_box_office'
  resources :domestic_box_office, only: [:index] 
  
  resources "trends"

  resources "movie_genres"

  resources "movies", param: :tmdb_id, only: [:show] #view for individual movie data

  resources "companies" do 
    collection do 
      get 'top_companies'
      get 'search'
    end

    member do
      post 'add_company'
    end
  end
  
  # Login/logout
  get("/login", { :controller => "sessions", :action => "new" })
  get("/logout", { :controller => "sessions", :action => "destroy" })

  # Define the root route
  get("/", { :controller => "users", :action => "new" })
end
