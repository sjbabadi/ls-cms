require "sinatra"
require "sinatra/reloader"
require "tilt/erubis"
require "redcarpet"

root = File.dirname(__FILE__)

configure do
  enable :sessions
  set :session_secret, 'secret'
end

before do
  @files = Dir.glob("data/*").map { |file| File.basename(file) }
end

def markdown?(filename)
  File.extname(filename) == ".md"
end

def render_markdown(text) #takes in markdown text and returns rendered HTML
  markdown = Redcarpet::Markdown.new(Redcarpet::Render::HTML)
  markdown.render(text)
end

def load_file_content(path)
  content = File.read(path)
  case File.extname(path)
  when ".txt"
    headers["Content-Type"] = "text/plain"
    content
  when ".md"
    render_markdown(content)
  end
end

get "/" do
  erb :index
end

get "/:filename" do
  file_path = root + "/data/" + params[:filename]

  if File.file?(file_path)
    load_file_content(file_path)
  else
    session[:message] = "#{params[:filename]} does not exist."
    redirect "/"
  end
end

get "/:filename/edit" do
  file_path = root + "/data/" + params[:filename]
  @content = load_file_content(file_path)
  erb :edit_file
end

post "/:filename" do
  file_path = root + "/data/" + params[:filename]
  File.write(file_path, params[:new_content])
  session[:message] = "#{params[:filename]} has been updated."
  redirect "/"
end