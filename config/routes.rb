Rails.application.routes.draw do
  # Resources
  resources "sessions"
  resources "users"
  resources "dice"
  resources "home" #home page of app
  resources "trends" #tab for data analysis
  #resources "logged_movies" #tab for table of logged movies
  resources :logged_movies, param: :tmdb_id


  resources "movie_genres"

  resources "movies", only: [:show] #view for individual movie data
  resources "companies" 
  
  # Login/logout
  get("/login", { :controller => "sessions", :action => "new" })
  get("/logout", { :controller => "sessions", :action => "destroy" })

  # Define the root route
  get("/", { :controller => "users", :action => "new" })
end
