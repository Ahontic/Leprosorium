#encoding: utf-8
require 'rubygems'
require 'sinatra'
require 'sinatra/reloader'
require 'sqlite3'

def init_db
	@db = SQLite3::Database.new 'leprosorium.db'
	@db.results_as_hash = true
end

before do
	init_db
end

configure do
	init_db

	@db.execute 'CREATE TABLE IF NOT EXISTS Posts
	(  
	id INTEGER PRIMARY KEY AUTOINCREMENT,
    created_date DATE,
    content TEXT,
    username TEXT
    )'

	@db.execute 'CREATE TABLE IF NOT EXISTS Comments
	(  
	id INTEGER PRIMARY KEY AUTOINCREMENT,
    created_date DATE,
    content TEXT,
    post_id INTEGER
)';

end

get '/' do

	# выбираем список постов из БД

	@results = @db.execute 'select * from Posts order by id desc'

	erb :index
end

get '/new' do
	erb :new
end

post '/new' do
		username = params[:username]
		content = params[:content]


		hh = { 
				:username => 'Введите ваше имя',
				:content => 'Type text'

		}

		@error = hh.select {|key,_| params[key] == ""}.values.join(",")

		if @error != ''
				return erb :new
		end
# сохранение данных в БД
		@db.execute 'insert into Posts (content, created_date, username) values (?, datetime(),?)', [content,username]

		# перенаправление на главную
		redirect to '/'
		
	end

# вывод информации о посте
get '/details/:post_id' do

	# получаем переменную из url'a
	post_id = params[:post_id]

	# получаем список постов ( у нас будет только один пост)
	results = @db.execute 'select * from Posts where id = ?', [post_id]
	# выбираем этот один пост в переменную
	@row = results[0] 

	@comments = @db.execute 'select * from Comments where post_id = ? order by id', [post_id]



	# возвращаем прдставление details.erb
	erb :details

end

# обработчик зщые-куйгуые /details/.erb
# браузер отправляет данные на сервер, мы их принимаем

post '/details/:post_id' do
	post_id = params[:post_id]
	content = params[:content]


	@db.execute 'insert into Comments
	(
		content,
		created_date,
		post_id
	) 
		values
	(
	 	?,
	 	datetime(),
	 	?
	 )', [content,post_id]

	# перенаправление на страницу поста
		redirect to('/details/' + post_id)
		
end