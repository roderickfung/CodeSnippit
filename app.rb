require 'pry'
require 'sinatra'
require 'sinatra/reloader'
require 'sinatra/flash'
require 'dm-migrations'
require 'dm-validations'
require 'data_mapper'

enable :sessions

DataMapper.setup(:default, "sqlite3://#{Dir.pwd}/snippit.db")

class Account
  include DataMapper::Resource
  property :id, Serial
  property :username, String, required: true
  property :password, String, required: true, length: 8..30
  property :first_name, String, required: true
  property :last_name,String
  property :email, String, format: :email_address

  # has n, :snippit
end

class Snippit
  include DataMapper::Resource

  property :id, Serial
  property :title, String
  property :sniptype, String
  property :snippit, Text
  property :deleted, Boolean, default: false
  property :user_id, Integer
  # belongs_to :account
end

DataMapper.auto_upgrade!

# def count_languages(database)
#   languages = Array.new
#   language_count = Hash.new
#   database.each do |x|
#     languages << x.sniptype
#   end
#
#   languages.map{|x| language_count[x] ? language_count[x] += 1 : language_count[x] = 1}
#
#   language_count
# end


get '/' do
  # @language_count = count_languages(@snippit)

  @snipdata =  Snippit.all
  @snipdata.each do |x|
    if x.snippit == nil
      x.snippit = "BLANK"
    end
  end
  @sniptypedata = Snippit.all(sniptype: "Ruby")
  puts ">>>>>>>>>"
  puts @sniptypedata.count
  puts ">>>>>>>>>"
  puts @snipdata.count
  erb :index, layout: :default
end

post '/' do
  # flash[:notice] = "Hooray, Flash is working!"
  @sniptype = params[:sniptype]
  @title = params[:title]
  # @snip = params[:snippit].strip.gsub("&","&amp;").gsub("<","&lt;").gsub(">","&gt;").gsub("\"","&quot;").gsub("\'","&apos;").gsub!("\  ","&nbsp;&nbsp;")
  @snip = params[:snippit]
  @snippet = Snippit.create! title: @title, sniptype: @sniptype, snippit: @snip
  # p ">>>>>>> #{@snippet.errors.inspect}"
  # p Snippit.all
  redirect "/"
end

get '/snip' do
  @snippit = Snippit.all
  erb :snip, layout: :default
end

get "/snip/:id" do |x|
  @s_detail = Snippit.get x
  erb :snip_detail, layout: :default
end


get '/signin' do
erb :signin, layout: :default
end

post '/signin' do
  @username = params[:username]
  @password = params[:password]
  @f_name = params[:first_name]
  @l_name = params[:last_name]
  @email = params[:email]
  flash[:notice] = "Welcome, #{@f_name}!"
  erb :signin, layout: :default
end
