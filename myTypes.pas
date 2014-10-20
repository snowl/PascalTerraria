unit myTypes;
interface

uses sgTypes;

const
	//All constants in this section are offset by 1 due to 0-indexing.
	//***
	MAP_WIDTH = 63; //262144 block space (64*16*16*16)
	MAP_HEIGHT = 15;
	CHUNK_HEIGHT = 15;
	CHUNK_WIDTH = 15;
	BLOCK_COUNT = 11; //Amount of types of blocks
	//***

	ACCELERATION = 0.269;

type

	//Each block contains a bitmap and the location in the image file (not the world)
	Blocks = Record
				image: Bitmap;
				x: integer;
				y: integer;
			end;

	BlockArray = Record
					block: array [0..BLOCK_COUNT] of Blocks;
				end;

	//Chunks contain the integer index in the blockArray of what block it is
	ChunkArray = Record
					Blocks: array [0..CHUNK_WIDTH, 0..CHUNK_HEIGHT] of integer;
	             end;

	//The world contains multiple chunks, allowing for only visible blocks to be rendered without having to iterate through each block to check if its on screen.
	WorldArray = Record
					Chunks: array [0..MAP_WIDTH, 0..MAP_HEIGHT] of ChunkArray;
	             end;
	
	
	PlayerType = Record
					x: integer;
					y: integer;
					jumping: boolean;
					vertVelocity: single;
					speedVertical: single;
	
					speedHorizontal: single;
					leftMovement: boolean;
					rightMovement: boolean;
				  end;
implementation

end.