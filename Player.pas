unit Player;

interface
uses myTypes, sgTypes, SwinGame, Chunk;

procedure RenderPlayer(myPlayer: PlayerType; blocks: BlockArray);
procedure HandleGravity(var myPlayer: PlayerType; world: WorldArray);
procedure HandleMovement(var myPlayer: PlayerType; world: WorldArray);

implementation

procedure RenderPlayer(myPlayer: PlayerType; blocks: BlockArray);
begin
	//Draw the player on the screen. Hardcoded to block item 2 with a size of 16 * 16, and always in the center of the screen.
	DrawBitmapPartOnScreen(blocks.block[2].image, blocks.block[2].x, blocks.block[2].y, 16, 16, Round(ScreenWidth() / 2), Round(ScreenHeight() / 2));
end;

procedure HandleGravity(var myPlayer: PlayerType; world: WorldArray);
var 
	tempY: integer;
	collided: boolean;
	radiusx, radiusy, x, y, b: integer;
	rectA, rectB: Rectangle;
begin
	if myPlayer.jumping then
	begin
		//Increase players velocity
		if myPlayer.vertVelocity < 12 then
		begin
			myPlayer.vertVelocity += 1;
			myPlayer.speedVertical += 1.6;
		end;
	end;

	//Take the amount of speed so if it is still going up, it goes up by .6, but then starts to go down resulting in an arc.
	myPlayer.speedVertical -= 1;

	//Limit the speed the player can go (it will start clipping through blocks if going to fast)
	if myPlayer.speedVertical < -8 then
	begin
		myPlayer.speedVertical := -8;
	end;

	collided := false;
	//Get the players location after falling to check if there is a block there
	tempY := Round(myPlayer.y - myPlayer.speedVertical);

	//Check for blocks in a 2*2 (could be a 1*1 but this is just to make sure for edge cases)
	for radiusx := 0 to 2 do
	begin
		for radiusy := 0 to 2 do
		begin
			x := myPlayer.X + (radiusx * 16);
			y := tempY + (radiusy * 16);
			b := Chunk.GetBlock(world, x, y);
			if (b >= 0) and (b <> 10) then
			begin
				rectA.x := x;
				rectA.y := y;
				rectA.width := 16;
				rectA.height := 16;

				rectB.x := myPlayer.x;
				rectB.y := tempY;
				rectB.width := 16;
				rectB.height := 16;

				if RectanglesIntersect(rectA, rectB) then
				begin
					//Stop falling and don't set the location since that location contains a block.
					myPlayer.jumping := false;
					myPlayer.speedVertical := 0;
					myPlayer.vertVelocity := 0;
					collided := true;
					Break;
				end;
			end;
		end;
	end;

	if not collided then
	begin
		myPlayer.y := tempY;
	end;
end;

procedure HandleMovement(var myPlayer: PlayerType; world: WorldArray);
var
	tempX: integer;
	collided: boolean;
	radiusx, radiusy, x, y, b: integer;
	rectA, rectB: Rectangle;
begin
	//Acceleration slowly by the ACCELERATION constant, limited to 7 pixels in either direction
	if myPlayer.leftMovement then
	begin
		myPlayer.speedHorizontal -= ACCELERATION;
		if myPlayer.speedHorizontal < -7 then
		begin
			myPlayer.speedHorizontal := -7;
		end;
	end
	else if myPlayer.rightMovement then
	begin
		myPlayer.speedHorizontal += ACCELERATION;
		if myPlayer.speedHorizontal > 7 then
		begin
			myPlayer.speedHorizontal := 7;
		end;
	end
	else
	begin
		//Slow down slowly instead of stopping abruptly
		if myPlayer.speedHorizontal > 0.2 then
		begin
			myPlayer.speedHorizontal -= ACCELERATION;
		end
		else if myPlayer.speedHorizontal < -0.2 then
		begin
			myPlayer.speedHorizontal += ACCELERATION;
		end
		else
		begin
			//Stop moving when slow enough
			myPlayer.speedHorizontal := 0;
		end;
	end;

	collided := false;
	tempX := myPlayer.x - Round(myPlayer.speedHorizontal * -1);

	for radiusx := 0 to 2 do
	begin
		for radiusy := 0 to 2 do
		begin
			x := tempX + (radiusx * 16);
			y := myPlayer.y + (radiusy * 16);
			b := Chunk.GetBlock(world, x, y);
			if (b >= 0) and (b <> 10) then
			begin
				rectA.x := x;
				rectA.y := y;
				rectA.width := 16;
				rectA.height := 16;

				rectB.x := tempX;
				rectB.y := myPlayer.y;
				rectB.width := 16;
				rectB.height := 16;

				if RectanglesIntersect(rectA, rectB) then
				begin
					//Don't move if the location moving to contains a block.
					myPlayer.speedHorizontal := 0;
					collided := true;
					Break;
				end;
			end;
		end;
	end;

	if not collided then
	begin
		myPlayer.x := tempX;
	end;
end;

end.