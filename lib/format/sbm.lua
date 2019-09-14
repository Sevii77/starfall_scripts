--[[
SBM Simple Binary Model

All floats are single-precision 32 bit
Rotations in degrees
An object segment is a collection of vertices with a different material
Material index being 0 means it has no material


material flags:
	0x01 = material contains transparency
	
	0x04 = material contains an ambient map
	0x08 = ambient is local path to ambient file
	
	0x10 = material contains an diffuse map
	0x20 = diffuse is local path to diffuse file
	
	0x40 = material contains an normal map
	0x80 = normal is local path to normal file

object flags:
	0x01 = vertices contains normals
	0x02 = vertices contains uv's
	0x04 = model contains bones


byte	- SBM version
byte	- material count
per material:
	byte	- material flags
	byte	- length of name
	string 	- name
	byte	- length of ambient map path (if 0x04 and 0x08 set)
	string	- path or data for ambient map (if 0x04 set)
	byte	- length of diffuse map path (if 0x10 and 0x20 set)
	string	- path or data for diffuse map (if 0x10 set)
	byte	- length of normal map path (if 0x40 and 0x80 set)
	string	- path or data for normal map (if 0x40 set)
8 bit - object count
per object:
	byte	- object flags
	byte	- length of name
	string	- name
	float	- position x
	float	- position y
	float	- position z
	float	- rotation x
	float	- rotation y
	float	- rotation z
	float	- scale x
	float	- scale y
	float	- scale z
	short	- bone count (if 0x04 set)
	per bone:
		todo
	short	- vertex count
	per vertex:
		float	- position z
		float	- position y
		float	- position z
		float	- normal z (if 0x01 set)
		float	- normal y (if 0x01 set)
		float	- normal z (if 0x01 set)
		float	- u (if 0x02 set)
		float	- v (if 0x02 set)
		short	- bone id (if 0x04 set)
	byte	- segment count
	per segment:
		byte	- material index
		short	- triangle count
		per triangle:
			short	- vertex index
			short	- vertex index
			short	- vertex index
]]
