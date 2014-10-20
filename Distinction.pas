program Distinction;
uses SwinGame, myTypes, sgTypes, Chunk, Player, Math;

function CreateInitialWorld(): WorldArray;
var
	x, y, k, l: Integer;
	tempArray: WorldArray;
	tempChunkArray: ChunkArray;
begin
	for x := 0 to MAP_WIDTH do
	begin
		for y := 0 to MAP_HEIGHT do
		begin
			tempChunkArray := tempArray.Chunks[x, y];

			for k := 0 to CHUNK_WIDTH do
			begin
				for l := 0 to CHUNK_HEIGHT do
				begin
					//If it is the second chunk, make it look pretty by having one of grass
					if y = 1 then
					begin
						tempChunkArray.Blocks[k, l] := 5;
						tempChunkArray.Blocks[k, 0] := 4; //Make the first row grass
					end
					else if y > 1 then
					begin
						tempChunkArray.Blocks[k, l] := 5;
					end
					else
					begin
						tempChunkArray.Blocks[k, l] := 10;
					end;
				end;
			end;

			tempArray.Chunks[x, y] := tempChunkArray;
		end;
	end;
	result := tempArray;
end; 

function GenerateBlockArray(): BlockArray;
var 
	tempArray: BlockArray;
	tempBitmap: Bitmap;
	x: integer;
begin
	tempBitmap := LoadBitmap('Textures.png');
	SetTransparentColor(tempBitmap, RGBColor(255, 0, 255));
	OptimiseBitmap(tempBitmap);

	//Iterate through the first row
	for x := 0 to 5 do
	begin
		tempArray.block[x].image := tempBitmap;
		tempArray.block[x].x := (x * 16);
		tempArray.block[x].y := 0;
	end;

	//And then the second row
	for x := 6 to 11 do
	begin
		tempArray.block[x].image := tempBitmap;
		tempArray.block[x].x := ((x - 6) * 16);
		tempArray.block[x].y := 16;
	end;

	result := tempArray;
end;

//Handle the input in both mouse & keyboard

procedure HandleInput(var myPlayer: PlayerType; var world: WorldArray);
var
	tempX, tempY: integer;
	deferredX, deferredY: integer;
	tempBlock: integer;
begin
	//This is not an else if as you want to parse all 3 inputs, not ignore if a certain input is pressed
	if KeyDown(VK_SPACE) then
	begin
		myPlayer.jumping := true;
	end;

	if KeyDown(VK_LEFT) then
	begin
		myPlayer.leftMovement := true; 
	end
	else
	begin
		myPlayer.leftMovement := false; 
	end;

	if KeyDown(VK_RIGHT) then
	begin
		myPlayer.rightMovement := true; 
	end
	else
	begin
		myPlayer.rightMovement := false; 
	end;

	//Put rectangle in "grid" - remove the remainder so it locks into a grid.
	tempX := Floor(MouseX() / 16);
	tempY := Floor(MouseY() / 16);

	tempX *= 16;
	tempY *= 16;

	//Make sure the rectangle lines up with the blocks
	tempX -= myPlayer.X mod 16;
	tempY -= myPlayer.Y mod 16;

	//-4 is required to make it line up on the block in widescreen. With 800*800 it is not needed
	DrawRectangle(ColorWhite, tempX, tempY - 4, 16, 16);

	deferredX := Round((-myPlayer.X) + (ScreenWidth() / 2));
	deferredY := Round((-myPlayer.Y) + (ScreenHeight() / 2));

	if MouseDown(LeftButton) then
	begin
		Chunk.SetBlock(world, tempX - deferredX, tempY - deferredY, 5);
	end
	else if MouseClicked(WheelUpButton) then
	begin
		tempBlock := Chunk.GetBlock(world, tempX - deferredX, tempY - deferredY) + 1;
		if tempBlock > BLOCK_COUNT then
		begin
			tempBlock := 0;
		end;
		Chunk.SetBlock(world, tempX - deferredX, tempY - deferredY, tempBlock);
	end
	else if MouseClicked(WheelDownButton) then
	begin
		tempBlock := Chunk.GetBlock(world, tempX - deferredX, tempY - deferredY) - 1;
		if tempBlock < 0 then
		begin
			tempBlock := BLOCK_COUNT;
		end;
		Chunk.SetBlock(world, tempX - deferredX, tempY - deferredY, tempBlock);
	end
	else if MouseDown(RightButton) then
	begin
		Chunk.SetBlock(world, tempX - deferredX, tempY - deferredY, 10);
	end;
end;

procedure DrawInformation(MyPlayer: PlayerType);
var 
	fps, x, y: string;
begin
	Str(GetFramerate(), fps);
	Str(Floor(MyPlayer.x / 16), x);
	Str(Floor(MyPlayer.y / 16), y);
	DrawText(fps + 'FPS | (' + x + ', ' + y + ')', ColorBlack, FontNamed('FPS'), 12, 12);
	DrawText(fps + 'FPS | (' + x + ', ' + y + ')', ColorWhite, FontNamed('FPS'), 10, 10);
end;

procedure RenderWorld(World: WorldArray; BlockList: BlockArray; MyPlayer: PlayerType);
var
	CurrentChunkLoc: Point2d;
	x, y: Integer;
begin
	CurrentChunkLoc := Chunk.GetChunkNumber(MyPlayer.x, MyPlayer.y); 

	//Render only what the player can see
	for y := Max(0, Floor(CurrentChunkLoc.y) - 2) to Min(MAP_HEIGHT, Floor(CurrentChunkLoc.y) + 2) do
	begin
	    for x := Max(0, Floor(CurrentChunkLoc.x) - 2) to Min(MAP_WIDTH, Floor(CurrentChunkLoc.x) + 2) do
		begin
			Chunk.RenderChunk((x * 256), (y * 256), MyPlayer, World.Chunks[x, y], BlockList);
		end;
	end;
end;

procedure HandlePlayer(var World: WorldArray; BlockList: BlockArray; var MyPlayer: PlayerType);
begin
	HandleInput(MyPlayer, World);
	Player.HandleGravity(MyPlayer, World);
	Player.HandleMovement(MyPlayer, World);
	Player.RenderPlayer(MyPlayer, BlockList);
end;

procedure Main();
var
	World: WorldArray;
	BlockList: BlockArray;
	MyPlayer: PlayerType;
begin
	OpenGraphicsWindow('Terraria', 800, 600);
	LoadDefaultColors();
	HideMouse();

	LoadFontNamed('FPS', 'arial.ttf', 14);

	BlockList := GenerateBlockArray();
	World := CreateInitialWorld();

	//Place the player in the middle of the map
	MyPlayer.x := Round((MAP_WIDTH * CHUNK_WIDTH * 16) / 2);
	MyPlayer.y := 0;
	MyPlayer.jumping := false;

	while not WindowCloseRequested() do
	begin
		ClearScreen(ColorBlack);
		ProcessEvents();

		RenderWorld(World, BlockList, MyPlayer);
		HandlePlayer(World, BlockList, MyPlayer);
		DrawInformation(MyPlayer);

		RefreshScreen(60);
	end;
end;

begin
	Main();
end.