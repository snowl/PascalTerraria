unit Chunk;

interface
uses myTypes, SwinGame, Math;
procedure RenderChunk(x, y: Integer; myPlayer: PlayerType; chunk:ChunkArray; blocks: BlockArray);
function GetBlock(world: WorldArray; x, y: integer): integer;
procedure SetBlock(var world: WorldArray; x, y, b: integer);
function GetChunkNumber(x, y: integer): Point2D;

implementation

procedure RenderChunk(x, y: Integer; myPlayer: PlayerType; chunk:ChunkArray; blocks: BlockArray);
var
	j, i: integer;
	blockNo: integer;
	deferredX, deferredY: integer;
begin
	//Get the location of where the blocks should be displayed based off the players location. This can be negative as it always ensures that the blocks are loaded on screen.
	deferredX := Round((-myPlayer.X) + (ScreenWidth() / 2));
	deferredY := Round((-myPlayer.Y) + (ScreenHeight() / 2));

	for i := 0 to CHUNK_HEIGHT do
	begin
		for j := 0 to CHUNK_WIDTH do
		begin
			//Render each block image to the screen, since all images have been loaded in memory this is fairly easy.
			blockNo := chunk.Blocks[i, j];
			DrawBitmapPartOnScreen(blocks.block[blockNo].image, blocks.block[blockNo].x, blocks.block[blockNo].y, 16, 16, x + (i * 16) + deferredX, y + (j * 16) + deferredY);
		end;
	end;
end;

//These functions will get/set the block at a pixel location.

function GetBlock(world: WorldArray; x, y: integer): integer;
var
	cLoc: Point2D;
	myChunk: ChunkArray;
	chunkX, chunkY: integer;
begin
	cLoc := GetChunkNumber(x, y);

	if ((cLoc.x < 0) or (cLoc.x > MAP_WIDTH)) or
	   ((cLoc.Y < 0) or (cLoc.y > MAP_HEIGHT)) then
	begin
		result := -1;
		exit;
	end;

	myChunk := world.Chunks[Round(cLoc.x), Round(cLoc.y)];

	//Some modulo magic to find which block is at what (x, y) in the chunk
	chunkX := X mod 256;
	chunkY := Y mod 256;
	chunkX := Floor(chunkX / 16);
	chunkY := Floor(chunkY / 16);

	result := myChunk.blocks[chunkX, chunkY];
end;

procedure SetBlock(var world: WorldArray; x, y, b: integer);
var
	cLoc: Point2D;
	myChunk: ChunkArray;
	chunkX, chunkY: integer;
begin
	cLoc := GetChunkNumber(x, y);

	if ((cLoc.x < 0) or (cLoc.x > MAP_WIDTH)) or
	   ((cLoc.Y < 0) or (cLoc.y > MAP_HEIGHT)) then
	begin
		exit;
	end;

	chunkX := X mod 256;
	chunkY := Y mod 256;
	chunkX := Floor(chunkX / 16);
	chunkY := Floor(chunkY / 16);

	world.Chunks[Round(cLoc.x), Round(cLoc.y)].blocks[chunkX, chunkY] := b;
end;

function GetChunkNumber(x, y: integer): Point2D;
var
	tempPoint2d: Point2D;
begin
	//This will get the chunk at x, y
	tempPoint2d.x := Floor(x / 256);
	tempPoint2d.y := Floor(y / 256);
	result := tempPoint2d;
end;

end.