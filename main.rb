require 'dxopal'
include DXOpal

#-----ゲーム設定-----
item_max = 1			#アイテムの数
enemy_max = 1			#敵の数
light_size = 2			#自分の周りが見えるマス
enemy_speed = 60       #敵が動く速さ

ap_size = 20			#マップの大きさ
mapdraw_x = 430			#マップのx軸
mapdraw_y = 30			#マップのy軸

item_count = 0
t = 0
game = 0
enemy_move = 0
item_collect = 0

# #-----効果音-------
# sta = Sound.new("sound/start.wav")
# clear = Sound.new("sound/clear.wav")
# core = Sound.new("sound/core.wav")
# ho = Sound.new("sound/kou.wav")
# die = Sound.new("sound/die.wav")

# #------BGM--------
# taitolm = Sound.new("sound/taitol.mid")
# mainm = Sound.new("sound/main.mid")
# go = Sound.new("sound/gameover.mid")
# gc = Sound.new("sound/gameclear.mid")
# res1 = Sound.new("sound/result1.mid")
# res2 = Sound.new("sound/result2.mid")

#-----効果音-------
Sound.register(:sta, "sounds/start.wav")
Sound.register(:clear, "sounds/clear.wav")
Sound.register(:core, "sounds/core.wav")
Sound.register(:ho, "sounds/kou.wav")
Sound.register(:die, "sounds/die.wav")

#------BGM--------
Sound.register(:taitolm, "sounds/taitol.mp3")
Sound.register(:mainm, "sounds/main.mp3")
# Sound.register(:go, "sounds/gameover.mid")
# Sound.register(:gc, "sounds/gameclear.mid")
# Sound.register(:res1, "sounds/result1.mid")
# Sound.register(:res2, "sounds/result2.mid")

#-----マップの大きさを決定-----
  item_max = 2			# アイテムの数
	enemy_max = 1			# 敵の数
	map_size = 10			# マップの大きさ

if map_size % 2 == 0
  map_size -= 1
end
map = Array.new(map_size){Array.new(map_size, 0)}	#マップ配列の生成
#-----マップの大きさを決定-----

#-----マップタイルの生成-----
tile_size = 10 	# タイル一つ分の大きさを調整
map_tile = []				# 配列の宣言
map_tile[0] = Image.new(tile_size, tile_size, [200,200,200])  # 床
map_tile[1] = Image.new(tile_size, tile_size, [100,100,100]) 	# 通った場所
map_tile[2] = Image.new(tile_size, tile_size, [75,75,75])		  # 外壁
map_tile[3] = Image.new(tile_size, tile_size, [150,150,150])	# 内壁
map_tile[4] = Image.new(tile_size, tile_size, [255,0,0])		  # 敵
map_tile[5] = Image.new(tile_size, tile_size, [0,255,0])		  # プレイヤー
map_tile[6] = Image.new(tile_size, tile_size, [255,255,0])	  # アイテム
#-----マップタイルの生成-----

#-----マップの中身を生成-----
player_x = 1						#プレイヤーのx座標
player_y = 1						#プレイヤーのy座標
map[player_y][player_x] = 5			#プレイヤー

#迷路の外枠の壁と迷路製作の軸になる壁を生成
i = 0
while i <  map_size do
	for j in 0 .. map_size-1
		if (i == 0 || j == 0 || i == map_size-1 || j == map_size-1) && map[j][i] == 0
			map[j][i] = 2
		elsif i % 2 == 0 && j % 2 == 0 && map[j][i] == 0
			map[j][i] = 3
		end
	end
  i += 1
end

#迷路の壁を生成
i = 2
while i < map_size-2 
	for j in 2 .. map_size-3
		block_cover = 1
		while block_cover == 1
			a = 0
			block_cover = 0
			if i == 2 && j % 2 == 0 && j != 2
				a = Random.rand(6)+1
			elsif i % 2 == 0 && j % 2 == 0 && i != 2
				a = Random.rand(5)+2
			end
		 	case a
		 	when 1
		 		if map[i-1][j] == 0
		 			map[i-1][j] = 3
		 		else	
		 			block_cover = 1
				end
		 	when 2
		 		if map[i][j-1] == 0
		 			map[i][j-1] = 3
		 		else
					block_cover = 1
				end
		  	when 3
		  		if map[i][j+1] == 0
		 			map[i][j+1] = 3
		 		else
					block_cover = 1
				end
		 	when 4
		 		if map[i+1][j] == 0
		 			map[i+1][j] = 3
		 		else
					block_cover = 1
				end
			when 5,6
			
			end
		end		 
	end
  i += 1
end

#迷路のアイテムを生成
while item_max != item_count
  i = 1
	while i < map_size-1
		for j in 1 .. map_size-2
			wall_count = 0
			a = -999
			if map[i-1][j] >= 2 && map[i-1][j] <= 3
				wall_count += 1
			end
			if map[i][j-1] >= 2 && map[i][j-1] <= 3
				wall_count += 1
			end
			if map[i][j+1] >= 2 && map[i][j+1] <= 3
				wall_count += 1
			end
			if map[i+1][j] >= 2 && map[i+1][j] <= 3
				wall_count += 1
			end
			
			if wall_count != 2
				a = Random.rand(map_size)
			end
			
			if a == 0 && map[i][j] == 0 && item_max != item_count 
				map[i][j] = 6
				item_count += 1
			end
		end
    i += 1
	end
end

class Enemy < Sprite  #敵の動き
	attr_accessor :map,:game
	def initialize(map,map_size,tile_size)
		@check = 0
		@map_size = map_size
		@tile_size = tile_size
		@map = map
		@wall_count = 0
		@old_mode = []
		while @check == 0
			self.x=Random.rand(@map_size - 5) + 3
			self.y=Random.rand(@map_size - 5) + 3
			if map[self.y-1][self.x] >= 2 && map[self.y-1][self.x] <= 6
				@wall_count += 1
			end
			if map[self.y][self.x-1] >= 2 && map[self.y][self.x-1] <= 6
				@wall_count += 1
			end
			if map[self.y][self.x+1] >= 2 && map[self.y][self.x+1] <= 6
				@wall_count += 1
			end
			if map[self.y+1][self.x] >= 2 && map[self.y+1][self.x] <= 6
				@wall_count += 1
			end
			if @map[self.y][self.x] == 0 && @wall_count != 4
				@check = 1
				map[self.y][self.x] = 4
			end
		end
	end
	def move(enemy_count)
		@mode = []
		@check = 0
		@wall_count = 0
		@game = 1
		if map[self.y-1][self.x] >= 2 && map[self.y-1][self.x] <= 3
			@wall_count += 1
		end
		if map[self.y][self.x-1] >= 2 && map[self.y][self.x-1] <= 3
			@wall_count += 1
		end
		if map[self.y][self.x+1] >= 2 && map[self.y][self.x+1] <= 3
			@wall_count += 1
		end
		if map[self.y+1][self.x] >= 2 && map[self.y+1][self.x] <= 3
			@wall_count += 1
		end
		while @check == 0
			if @map[self.y-1][self.x] == 5
				@mode[enemy_count] = 1
			elsif @map[self.y][self.x-1] == 5
				@mode[enemy_count] = 2
			elsif @map[self.y][self.x+1] == 5
				@mode[enemy_count] = 3
			elsif @map[self.y+1][self.x] == 5
				@mode[enemy_count] = 4
			elsif @wall_count == 2 && ((@old_mode[enemy_count] == 1 && @map[self.y-1][self.x] == 0) || (@old_mode[enemy_count] == 2 && @map[self.y][self.x-1] == 0) || (@old_mode[enemy_count] == 3 && @map[self.y][self.x+1] == 0) || (@old_mode[enemy_count] == 4 && @map[self.y+1][self.x] == 0))
				@mode[enemy_count] = @old_mode[enemy_count]
			else
				@mode[enemy_count] = Random.rand(4)+1
			end
			if @mode[enemy_count] == 1 && @map[self.y-1][self.x] == 0 || @map[self.y-1][self.x] == 5
				@game = 2 if map[self.y-1][self.x] == 5
				map[self.y][self.x] = 0
				map[self.y-1][self.x] = 4	
				self.y -= 1
				@check = 1
			elsif @mode[enemy_count] == 2 && @map[self.y][self.x-1] == 0 || @map[self.y][self.x-1] == 5
				@game = 2 if map[self.y][self.x-1] == 5
				map[self.y][self.x] = 0
				map[self.y][self.x-1] = 4			
				self.x -= 1
				@check = 1
			elsif @mode[enemy_count] == 3 && @map[self.y][self.x+1] == 0 || @map[self.y][self.x+1] == 5
				@game = 2 if map[self.y][self.x+1] == 5
				map[self.y][self.x] = 0
				map[self.y][self.x+1] = 4			
				self.x += 1
				@check = 1
			elsif @mode[enemy_count] == 4 && @map[self.y+1][self.x] == 0 || @map[self.y+1][self.x] == 5
				@game = 2 if map[self.y+1][self.x] == 5
				map[self.y][self.x] = 0
				map[self.y+1][self.x] = 4			
				self.y += 1
				@check = 1
			elsif @map[self.y-1][self.x] != 0 && @map[self.y][self.x-1] != 0 && @map[self.y][self.x+1] != 0 && @map[self.y+1][self.x] != 0
				@check = 1
			end
		end
		@old_mode[enemy_count] = @mode[enemy_count]
	end
end

x = 1
y = 1
angle = 1

map_image = Array.new(4){Array.new(3,0)}	#マップ配列の生成

menu = Sprite.new(0,0,Image.load("images/tai5.png"))
R1 = Sprite.new(125,400,Image.load("images/strat.png"))
R2 = Sprite.new(125,400,Image.load("images/start.png"))
S1 = Sprite.new(125,515,Image.load("images/説明1.png"))
S2 = Sprite.new(125,515,Image.load("images/説明2.png"))
Tait = Sprite.new(0,50,Image.load("images/taitoru.png"))
result = Sprite.new(0,0,Image.load("images/result.png"))
gameover = Sprite.new(0,0,Image.load("images/gameover.png"))
gameclear = Sprite.new(0,0,Image.load("images/gameclear.png"))
setumei = Sprite.new(0,0,Image.load("images/説明画面.png"))

Image.register(:menu, "images/tai5.png")
Image.register(:R1, "images/strat.png")
Image.register(:R2, "images/start.png")
Image.register(:S1, "images/説明1.png")
Image.register(:S2, "images/説明2.png")
Image.register(:Tait, "images/taitoru.png")
Image.register(:result, "images/result.png")
Image.register(:gameover, "images/gameover.png")
Image.register(:gameclear, "images/gameclear.png")
Image.register(:setumei, "images/説明画面.png")

enemy=[]
enemy_max.times do
	enemy << Enemy.new(map,map_size,tile_size)
end
font=Font.new(100)
font2=Font.new(50)
font3=Font.new(25)

#-----画面の大きさを設定-----
Window.width = 500
Window.height = 600
#-----画面の大きさを設定-----

way = ["上","右","下","左"]

# w_r1 = Image.load("image3/red_R1.png")
# w_r2 = Image.load("image3/red_R2.png")
# w_r3 = Image.load("image3/red_R3.png")
# w_r4 = Image.load("image3/red_R4.png")
# w_l1 = Image.load("image3/red_L1.png")
# w_l2 = Image.load("image3/red_L2.png")
# w_l3 = Image.load("image3/red_L3.png")
# w_l4 = Image.load("image3/red_L4.png")
# w_c1 = Image.load("image3/red_C1.png")
# w_c2 = Image.load("image3/red_C2.png")
# w_c3 = Image.load("image3/red_C3.png")
# w_c4 = Image.load("image3/red_C4.png")
# e2 = Image.load("image3/enemy2.png")
# e3 = Image.load("image3/enemy3.png")
# e4 = Image.load("image3/enemy4.png")
# i2 = Image.load("image3/item2.png")
# i3 = Image.load("image3/item3.png")
# i4 = Image.load("image3/item4.png")
# p1 = Image.load("image3/player.png")
# t1  = Image.load("image3/tile.png")

Image.register(:w_r1, "images/red_R1.png")
Image.register(:w_r2, "images/red_R2.png")
Image.register(:w_r3, "images/red_R3.png")
Image.register(:w_r4, "images/red_R4.png")
Image.register(:w_l1, "images/red_L1.png")
Image.register(:w_l2, "images/red_L2.png")
Image.register(:w_l3, "images/red_L3.png")
Image.register(:w_l4, "images/red_L4.png")
Image.register(:w_c1, "images/red_C1.png")
Image.register(:w_c2, "images/red_C2.png")
Image.register(:w_c3, "images/red_C3.png")
Image.register(:w_c4, "images/red_C4.png")
Image.register(:e2, "images/enemy2.png")
Image.register(:e3, "images/enemy3.png")
Image.register(:e4, "images/enemy4.png")
Image.register(:i2, "images/item2.png")
Image.register(:i3, "images/item3.png")
Image.register(:i4, "images/item4.png")
Image.register(:p1, "images/player.png")
Image.register(:t1, "images/tile.png")

#変数宣言
m = 0
m2 = 0
m3 = 0
t = 0
time = 0
second = 0
tsecond = 0
minute = 0
tminute = 0
hour = 0
restart = 0
mouse = Sprite.new
mouse.collision = [0,0]

Window.load_resources do
  Window.loop do
    mouse.x,mouse.y = Input.mouse_pos_x,Input.mouse_pos_y
    if game == 0 #タイトル
      if m == 0
        Sound[:taitolm].play
        m = 1
      end
      # Sprite.draw(menu)
      # Sprite.draw(R1)
      # Sprite.draw(S1)
      # Sprite.draw(Tait)
      Window.draw(0, 0, Image[:menu])
      Window.draw(125, 400, Image[:R1])
      Window.draw(125, 515, Image[:S1])
      Window.draw(0, 50, Image[:Tait])

      # hit = mouse.check(R1).first
      # hit_2 = mouse.check(S1).first
      # if hit != nil
      #   Sprite.draw(R2)
        if Input.mouse_push?(M_LBUTTON)
          # sta.play
          m = 0
          # taitolm.stop
          game = 1
        end
      # end
      
      # if hit_2 != nil
      #   Sprite.draw(S2)
        if Input.mouse_push?(M_RBUTTON)
          Sound[:sta].play
          m = 0
          Sound[:taitolm].stop
          game = 6
        end
      # end
    elsif game == 1 #ゴールしたか否か
      if m == 0
        Sound[:mainm].play
        m = 1
      end
      Window.draw_font(0,0," ITEM #{item_collect}/#{item_max}",font2)
      Window.draw_font(15,50,"ENEMY #{enemy_max}体",font2)
  
      if enemy_move == enemy_speed
        enemy_count = 0
        enemy.each do |enemy|
          enemy.move(enemy_count)
          enemy_count += 1
          if enemy.game == 2
            game = 2
          end
        end
        enemy_move = 0
      else
        enemy_move += 1
			end

			# 角度の切り替え	
			angle += 1 if Input.key_push?(K_RIGHT)
			angle -= 1 if Input.key_push?(K_LEFT) 
			angle = 0 if angle > 3
			angle = 3 if angle < 0
		
			# 3D画面描画
			i = 0
			while i < 4 do
				for j in 0..3
					case angle
					when 0
						jx = player_x + j - 1
						iy = player_y + i - 3
						if iy >= 0 && iy <= map_size-1 && jx >= 0 && jx <= map_size-1
							map_image[i][j] = map[iy][jx]
						else
							map_image[i][j] = 2
						end
					when 1
						jx = player_x + j
						iy = player_y + i - 1
						if iy >= 0 && iy <= map_size-1 && jx >= 0 && jx <= map_size-1
							map_image[3-j][i] = map[iy][jx] 
						else
							map_image[3-j][i] = 2
						end
					when 2
						jx = player_x + j - 1
						iy = player_y + i
						if iy >= 0 && iy <= map_size-1 && jx >= 0 && jx <= map_size-1
							map_image[3-i][2-j] = map[iy][jx]
						else
							map_image[3-i][2-j] = 2
						end
					when 3
						jx = player_x + j - 3
						iy = player_y + i - 1
						if iy >= 0 && iy <= map_size-1 && jx >= 0 && jx <= map_size-1
							map_image[j][2-i] = map[iy][jx] 
						else
							map_image[j][2-i] = 2
						end
					end
				end
				i += 1
			end

			#自分の周囲マップを表示
			x2 = 0
			y2 = 0
			y = player_y - light_size - 1
			while y <= player_y + light_size + 1
				for x in player_x - light_size - 1 .. player_x + light_size + 1
					if x2 == 0 || y2 == 0 || x2 == (light_size+1)*2 || y2 == (light_size+1)*2
						Window.draw(mapdraw_x+x2*tile_size,mapdraw_y+y2*tile_size, map_tile[1])
					elsif x >= 0 && x <= map_size - 1 && y >= 0 && y <= map_size - 1
						Window.draw(mapdraw_x+x2*tile_size,mapdraw_y+y2*tile_size, map_tile[map[y][x]])
					else
						Window.draw(mapdraw_x+x2*tile_size,mapdraw_y+y2*tile_size, map_tile[2])
					end
					x2 += 1
				end
				x2 = 0
				y2 += 1
				y += 1
			end

			Window.draw(  0, 405, Image[:t1])
			Window.draw(  0, 550, Image[:p1])
		
			Window.draw( 225, 375, Image[:w_l4]) if map_image[0][0] == 2 || map_image[0][0] == 3
			Window.draw( 175, 375, Image[:w_c4]) if map_image[1][0] != 2 && map_image[1][0] != 3 && (map_image[0][0] == 2 || map_image[0][0] == 3)
			Window.draw( 255, 375, Image[:w_r4]) if map_image[0][2] == 2 || map_image[0][2] == 3
			Window.draw( 275, 375, Image[:w_c4]) if map_image[1][2] != 2 && map_image[1][2] != 3 && (map_image[0][2] == 2 || map_image[0][2] == 3)
			Window.draw( 225, 405, Image[:i4])	if map_image[0][1] == 6
			
			Window.draw( 185, 365, Image[:e4])	if map_image[0][0] == 4
			Window.draw( 265, 365, Image[:e4]) 	if map_image[0][2] == 4

			Window.draw( 225, 375, Image[:w_c4]) if map_image[0][1] == 2 || map_image[0][1] == 3
			Window.draw( 175, 325, Image[:w_l3]) if map_image[1][0] == 2 || map_image[1][0] == 3
			Window.draw(  25, 325, Image[:w_c3]) if map_image[2][0] != 2 && map_image[2][0] != 3 && (map_image[1][0] == 2 || map_image[1][0] == 3)
			Window.draw( 275, 325, Image[:w_r3]) if map_image[1][2] == 2 || map_image[1][2] == 3
			Window.draw( 325, 325, Image[:w_c3]) if map_image[2][2] != 2 && map_image[2][2] != 3 && (map_image[1][2] == 2 || map_image[1][2] == 3)
			Window.draw( 175, 425, Image[:i3]) 	if map_image[1][1] == 6
			Window.draw( 225, 365, Image[:e4]) 	if map_image[0][1] == 4
			Window.draw(  65, 305, Image[:e3]) 	if map_image[1][0] == 4
			Window.draw( 285, 305, Image[:e3]) 	if map_image[1][2] == 4
			Window.draw( 175, 325, Image[:w_c3]) if map_image[1][1] == 2 || map_image[1][1] == 3
			Window.draw( 100, 250, Image[:w_l2]) if map_image[2][0] == 2 || map_image[2][0] == 3	
			Window.draw(-200, 250, Image[:w_c2]) if map_image[3][0] != 2 && map_image[3][0] != 3 && (map_image[2][0] == 2 || map_image[2][0] == 3)
			Window.draw( 325, 250, Image[:w_r2]) if map_image[2][2] == 2 || map_image[2][2] == 3
			Window.draw( 400, 250, Image[:w_c2]) if map_image[3][2] != 2 && map_image[3][2] != 3 && (map_image[2][2] == 2 || map_image[2][2] == 3)
			Window.draw( 100, 475, Image[:i2]) 	if map_image[2][1] == 6
			Window.draw( 175, 305, Image[:e3])	if map_image[1][1] == 4
			Window.draw(-150, 220, Image[:e2]) 	if map_image[2][0] == 4
			Window.draw( 325, 220, Image[:e2]) 	if map_image[2][2] == 4
			Window.draw( 100, 250, Image[:w_c2]) if map_image[2][1] == 2 || map_image[2][1] == 3
			Window.draw(   0, 150, Image[:w_l1]) if map_image[3][0] == 2 || map_image[3][0] == 3	
			Window.draw( 400, 150, Image[:w_r1]) if map_image[3][2] == 2 || map_image[3][2] == 3
			Window.draw( 100, 220, Image[:e2]) 	if map_image[2][1] == 4
			Window.draw(-200, 220, Image[:e2])	if map_image[3][0] == 4
			Window.draw( 400, 220, Image[:e2]) 	if map_image[3][2] == 4
			Window.draw(   0, 150, Image[:w_c1]) if map_image[3][1] == 2 || map_image[3][1] == 3

			t -= 1 if t != 0

		elsif game == 2
			# Sprite.draw(gameover)	#ゲームオーバー画面
			
			Sound[:mainm].stop
			if m2 == 0
				die.play
				m2=1
			end
			if m3 == 0
				go.play
				m3 += 1
			end
			t += 1
			if t >= 420
				go.stop
			end
			Window.draw_font(85,170," GAME",font,:color=>[200,0,0])
			Window.draw_font(85,320," OVER",font,:color=>[200,0,0])
			Window.draw_font(290,570,"エンターキーで次へ",font3,:color=>[255,255,255])
			if  Input.key_push?(K_RETURN)
				game = 4
				m3 = 0
				m2 = 0
				m = 0
				go.stop
			end
		elsif game == 3
			Sprite.draw(gameclear)	#ゲームクリア画面
			if m2 == 0
				clear.play
				m2 = 1
			end
			if m == 0
				gc.play
				m = 1
			end
			t += 1
			if t >= 420
				gc.stop
			end
			Window.draw_font(85,170," GAME",font,:color=>[0,0,200])
			Window.draw_font(65,320," CLEAR",font,:color=>[0,0,200])
			Window.draw_font(290,570,"エンターキーで次へ",font3,:color=>[0,0,0])
			if  Input.key_push?(K_RETURN)
				game = 5
				gc.stop
				m = 0
				m2 = 0
				t = 0
			end
		elsif game == 4 
			Sprite.draw(result)	#リザルト画面
			if m == 0
				res1.play
				m = 1
			end
			Window.draw_font(45,0," RESULT",font,:color=>[0,0,200])
			Window.draw_font(15,100,"経過時間",font3,:color=>[255,255,255])
			Window.draw_font(195,100,"#{second}",font3,:color=>[255,255,255])
			Window.draw_font(180,100,"#{tsecond}",font3,:color=>[255,255,255])
			Window.draw_font(155,100,"#{minute}：",font3,:color=>[255,255,255])
			Window.draw_font(140,100,"#{tminute}",font3,:color=>[255,255,255])
			Window.draw_font(115,100,"#{hour}：",font3,:color=>[255,255,255])
			Window.draw_font(15,150,"GAME OVER",font3,:color=>[255,0,0])
			Window.draw_font(15,200,"アイテム取得率 #{item_collect}/#{item_max}",font3,:color=>[255,255,255])
			Window.draw_font(300,325,"L_SHIFTで終了",font3,:color=>[255,255,255])
			Window.draw_font(0,325,"R_SHIFTでリスタート",font3,:color=>[255,255,255])
			exit if Input.key_push?(K_LSHIFT)
			 if Input.key_push?(K_RSHIFT)
				game = 1
				restart += 1
			end
		elsif game == 5
			Sprite.draw(result)	#リザルト画面
			if m == 0
				res2.play
				m = 1
			end
			Window.draw_font(45,0," RESULT",font,:color=>[0,0,200])
			Window.draw_font(15,100,"経過時間",font3,:color=>[255,255,255])
			Window.draw_font(195,100,"#{second}",font3,:color=>[255,255,255])
			Window.draw_font(180,100,"#{tsecond}",font3,:color=>[255,255,255])
			Window.draw_font(155,100,"#{minute}：",font3,:color=>[255,255,255])
			Window.draw_font(140,100,"#{tminute}",font3,:color=>[255,255,255])
			Window.draw_font(115,100,"#{hour}：",font3,:color=>[255,255,255])
			Window.draw_font(15,150,"GAME CLEAR",font3,:color=>[0,0,255])
			Window.draw_font(15,200,"アイテム取得率 #{item_collect}/#{item_max}",font3,:color=>[255,255,255])
			Window.draw_font(260,200,"PREFECT",font3,:color=>[255,255,0])
			Window.draw_font(15,250,"リスタート #{restart}回",font3,:color=>[255,255,255])
			Window.draw_font(300,325,"L_SHIFTで終了",font3,:color=>[255,255,255])
			exit if Input.key_push?(K_LSHIFT)
			
		elsif game == 6	
			#Sprite.draw(setumei) #ゲーム説明
			Window.draw(0, 0, Image[:setumei])
			Window.draw_font(295,550,"エンターキーで戻る",font3,:color=>[255,255,255])
			if Input.key_push?(K_RETURN)
				game = 0 
			end
    end
  end
end

