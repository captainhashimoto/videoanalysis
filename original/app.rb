require 'bundler/setup'
Bundler.require
require 'sinatra/reloader' if development?
require 'open-uri'
require 'json'
require 'net/http'

require 'sinatra/activerecord'
require './models'

require 'tempfile'

enable :sessions

helpers do
  def current_user
    User.find_by(id: session[:user])
  end
end

get '/' do
  erb :index
end

get '/search' do
  @users = User.all
  erb :search
end

post '/search' do
  @users = User.all
  @videos = Video.where(athlete: params[:athlete]).where(event: params[:event]).order(id: "DESC")
  erb :search
end

get '/sign_up' do
  erb :sign_up
end

post '/sign_up' do
  @user = User.create(
    name: params[:name],
    password: params[:password]
  )
  if @user.persisted?
    session[:user] = @user.id
  end
  redirect '/'
end

get '/sign_in' do
  erb :sign_in
end

post '/sign_in' do
  user = User.find_by(name:params[:name])
  if user && user.authenticate(params[:password])
    session[:user] = user.id
    redirect '/'
  else
    redirect '/'
  end
end

get '/sign_out' do
  session[:user] = nil
  redirect '/'
end

get '/upload' do
  erb :upload
end

post '/upload' do
  def callback_auth
    uri = URI.parse 'https://accounts.google.com/o/oauth2/token'
    post_params = Hash.new
    post_params.store('code', params[:code])
    post_params.store('client_id','11274364654-bp711h4705fdut2v1ffug5p028eqtu77.apps.googleusercontent.com')
    post_params.store('client_secret','BXuYLen4Kyv4DygwwzUOZZbq')
    post_params.store('redirect_uri', 'http://localhost:32772/upload')
    post_params.store('grant_type', 'authorization_code')

    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE

    http.set_debug_output $stderr

    req = Net::HTTP::Post.new uri.path
    req.set_form_data(post_params)

    http.start do |h|
      response = h.request(req)
      result = JSON.parse(response.body)
      # ここにログインしているユーザーへアクセストークンを保存してあげる処理を書く
    end
    redirect '/upload'
  end
  authorization = Signet::OAuth2::Client.new(
    access_token: access_token,
    expires_at: Time.current.since(1.hour)
  )

  file = params[:upload_file].tempfile.path
  youtube = Google::Apis::YoutubeV3::YouTubeService.new
  youtube.authorization = authorization

   part = {
     snippet: {
       title: 'hoge',
       description: 'fuga',
       tags: {}
     }
  }
  response = youtube.insert_video('snippet', part, upload_source: file, content_type: 'video/*')
end

get '/new' do
  @users = User.all
  erb :new
end

post '/new' do
  user = User.find(session[:user])
  video = Video.create(
    image_url: "http://img.youtube.com/vi/params[:video_id]/mqdefault.jpg",
    user_name: user.name,
    athlete: params[:athlete],
    event: params[:event],
    video_id: params[:video_id],
    commnet: params[:commnet],
    user_id: user.id
  )
  redirect '/new'
end

before '/home' do
  if current_user.nil?
    redirect '/sign_up'
  end
end

get '/home' do
  @videos = Video.where(athlete: current_user.name).order(id: "DESC")
  erb :home
end