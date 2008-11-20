# line 1 "lib/marvin/parsers/ragel_parser.rl"
# line 107 "lib/marvin/parsers/ragel_parser.rl"


module Marvin
  module Parsers
    class RagelParser < Marvin::AbstractParser
      
      
# line 11 "lib/marvin/parsers/ragel_parser.rb"
class << self
	attr_accessor :_irc_actions
	private :_irc_actions, :_irc_actions=
end
self._irc_actions = [
	0, 1, 1, 1, 2, 1, 4, 1, 
	5, 1, 6, 1, 7, 1, 9, 1, 
	12, 1, 17, 1, 18, 2, 0, 1, 
	2, 1, 4, 2, 2, 7, 2, 3, 
	4, 2, 8, 9, 2, 13, 17, 2, 
	14, 18, 2, 15, 12, 2, 16, 12, 
	2, 17, 18, 3, 10, 11, 12, 3, 
	10, 11, 17, 3, 13, 15, 12, 3, 
	14, 16, 12, 3, 15, 16, 12, 4, 
	0, 1, 3, 4, 4, 13, 17, 14, 
	18, 5, 13, 15, 14, 16, 12
]

class << self
	attr_accessor :_irc_key_offsets
	private :_irc_key_offsets, :_irc_key_offsets=
end
self._irc_key_offsets = [
	0, 0, 7, 9, 11, 13, 14, 19, 
	23, 28, 32, 37, 41, 46, 50, 55, 
	59, 64, 68, 73, 77, 82, 86, 91, 
	95, 100, 104, 109, 113, 118, 122, 127, 
	131, 136, 140, 144, 147, 150, 153, 156, 
	159, 171, 174, 180, 186, 194, 197, 204, 
	214, 223, 228, 233, 245, 248, 256, 259, 
	266, 276, 291, 301, 316, 322, 329, 335, 
	342, 348, 355, 361, 368, 374, 381, 387, 
	394, 400, 407, 414, 421, 428, 435, 442, 
	449, 456, 463, 472, 479, 485, 493, 495, 
	498, 500, 503, 505, 508, 511, 512, 515, 
	516, 519, 520, 528, 536, 545, 554, 563, 
	572, 581, 590, 599, 608, 617, 626, 635, 
	644, 653, 662, 671, 680, 689, 692, 702, 
	719, 736, 753, 770, 787, 804, 821, 838, 
	855, 872, 889, 906, 923, 940, 957, 969
]

class << self
	attr_accessor :_irc_trans_keys
	private :_irc_trans_keys, :_irc_trans_keys=
end
self._irc_trans_keys = [
	58, 48, 57, 65, 90, 97, 122, 48, 
	57, 48, 57, 13, 32, 10, 0, 10, 
	13, 32, 58, 0, 10, 13, 32, 0, 
	10, 13, 32, 58, 0, 10, 13, 32, 
	0, 10, 13, 32, 58, 0, 10, 13, 
	32, 0, 10, 13, 32, 58, 0, 10, 
	13, 32, 0, 10, 13, 32, 58, 0, 
	10, 13, 32, 0, 10, 13, 32, 58, 
	0, 10, 13, 32, 0, 10, 13, 32, 
	58, 0, 10, 13, 32, 0, 10, 13, 
	32, 58, 0, 10, 13, 32, 0, 10, 
	13, 32, 58, 0, 10, 13, 32, 0, 
	10, 13, 32, 58, 0, 10, 13, 32, 
	0, 10, 13, 32, 58, 0, 10, 13, 
	32, 0, 10, 13, 32, 58, 0, 10, 
	13, 32, 0, 10, 13, 32, 58, 0, 
	10, 13, 32, 0, 10, 13, 32, 58, 
	0, 10, 13, 32, 0, 10, 13, 58, 
	0, 10, 13, 0, 10, 13, 0, 10, 
	13, 0, 10, 13, 0, 10, 13, 42, 
	43, 48, 57, 65, 90, 91, 96, 97, 
	122, 123, 125, 32, 46, 47, 48, 57, 
	65, 90, 97, 122, 13, 32, 65, 90, 
	97, 122, 32, 42, 48, 57, 65, 90, 
	97, 122, 32, 46, 47, 42, 48, 57, 
	65, 90, 97, 122, 32, 45, 46, 47, 
	48, 57, 65, 90, 97, 122, 32, 33, 
	43, 45, 64, 48, 57, 65, 125, 0, 
	10, 13, 32, 64, 0, 10, 13, 32, 
	64, 42, 48, 49, 57, 65, 70, 71, 
	90, 97, 102, 103, 122, 32, 46, 47, 
	32, 42, 48, 57, 65, 90, 97, 122, 
	32, 46, 47, 42, 48, 57, 65, 90, 
	97, 122, 32, 45, 46, 47, 48, 57, 
	65, 90, 97, 122, 32, 45, 58, 46, 
	47, 48, 57, 65, 70, 71, 90, 97, 
	102, 103, 122, 32, 45, 46, 47, 48, 
	57, 65, 90, 97, 122, 32, 45, 58, 
	46, 47, 48, 57, 65, 70, 71, 90, 
	97, 102, 103, 122, 48, 57, 65, 70, 
	97, 102, 58, 48, 57, 65, 70, 97, 
	102, 48, 57, 65, 70, 97, 102, 58, 
	48, 57, 65, 70, 97, 102, 48, 57, 
	65, 70, 97, 102, 58, 48, 57, 65, 
	70, 97, 102, 48, 57, 65, 70, 97, 
	102, 58, 48, 57, 65, 70, 97, 102, 
	48, 57, 65, 70, 97, 102, 58, 48, 
	57, 65, 70, 97, 102, 48, 57, 65, 
	70, 97, 102, 58, 48, 57, 65, 70, 
	97, 102, 48, 57, 65, 70, 97, 102, 
	32, 48, 57, 65, 70, 97, 102, 48, 
	49, 57, 65, 70, 97, 102, 58, 48, 
	57, 65, 70, 97, 102, 48, 49, 57, 
	65, 70, 97, 102, 58, 48, 57, 65, 
	70, 97, 102, 48, 49, 57, 65, 70, 
	97, 102, 58, 48, 57, 65, 70, 97, 
	102, 48, 49, 57, 65, 70, 97, 102, 
	58, 48, 57, 65, 70, 97, 102, 48, 
	70, 102, 49, 57, 65, 69, 97, 101, 
	58, 48, 57, 65, 70, 97, 102, 48, 
	57, 65, 70, 97, 102, 46, 58, 48, 
	57, 65, 70, 97, 102, 48, 57, 46, 
	48, 57, 48, 57, 46, 48, 57, 48, 
	57, 32, 48, 57, 32, 48, 57, 32, 
	46, 48, 57, 46, 46, 48, 57, 46, 
	46, 58, 48, 57, 65, 70, 97, 102, 
	46, 58, 48, 57, 65, 70, 97, 102, 
	58, 70, 102, 48, 57, 65, 69, 97, 
	101, 58, 70, 102, 48, 57, 65, 69, 
	97, 101, 58, 70, 102, 48, 57, 65, 
	69, 97, 101, 32, 33, 43, 45, 64, 
	48, 57, 65, 125, 32, 33, 43, 45, 
	64, 48, 57, 65, 125, 32, 33, 43, 
	45, 64, 48, 57, 65, 125, 32, 33, 
	43, 45, 64, 48, 57, 65, 125, 32, 
	33, 43, 45, 64, 48, 57, 65, 125, 
	32, 33, 43, 45, 64, 48, 57, 65, 
	125, 32, 33, 43, 45, 64, 48, 57, 
	65, 125, 32, 33, 43, 45, 64, 48, 
	57, 65, 125, 32, 33, 43, 45, 64, 
	48, 57, 65, 125, 32, 33, 43, 45, 
	64, 48, 57, 65, 125, 32, 33, 43, 
	45, 64, 48, 57, 65, 125, 32, 33, 
	43, 45, 64, 48, 57, 65, 125, 32, 
	33, 43, 45, 64, 48, 57, 65, 125, 
	32, 33, 43, 45, 64, 48, 57, 65, 
	125, 32, 33, 64, 32, 45, 46, 47, 
	48, 57, 65, 90, 97, 122, 32, 33, 
	43, 45, 64, 46, 47, 48, 57, 65, 
	90, 91, 96, 97, 122, 123, 125, 32, 
	33, 43, 45, 64, 46, 47, 48, 57, 
	65, 90, 91, 96, 97, 122, 123, 125, 
	32, 33, 43, 45, 64, 46, 47, 48, 
	57, 65, 90, 91, 96, 97, 122, 123, 
	125, 32, 33, 43, 45, 64, 46, 47, 
	48, 57, 65, 90, 91, 96, 97, 122, 
	123, 125, 32, 33, 43, 45, 64, 46, 
	47, 48, 57, 65, 90, 91, 96, 97, 
	122, 123, 125, 32, 33, 43, 45, 64, 
	46, 47, 48, 57, 65, 90, 91, 96, 
	97, 122, 123, 125, 32, 33, 43, 45, 
	64, 46, 47, 48, 57, 65, 90, 91, 
	96, 97, 122, 123, 125, 32, 33, 43, 
	45, 64, 46, 47, 48, 57, 65, 90, 
	91, 96, 97, 122, 123, 125, 32, 33, 
	43, 45, 64, 46, 47, 48, 57, 65, 
	90, 91, 96, 97, 122, 123, 125, 32, 
	33, 43, 45, 64, 46, 47, 48, 57, 
	65, 90, 91, 96, 97, 122, 123, 125, 
	32, 33, 43, 45, 64, 46, 47, 48, 
	57, 65, 90, 91, 96, 97, 122, 123, 
	125, 32, 33, 43, 45, 64, 46, 47, 
	48, 57, 65, 90, 91, 96, 97, 122, 
	123, 125, 32, 33, 43, 45, 64, 46, 
	47, 48, 57, 65, 90, 91, 96, 97, 
	122, 123, 125, 32, 33, 43, 45, 64, 
	46, 47, 48, 57, 65, 90, 91, 96, 
	97, 122, 123, 125, 32, 33, 43, 45, 
	64, 46, 47, 48, 57, 65, 90, 91, 
	96, 97, 122, 123, 125, 32, 33, 45, 
	64, 46, 47, 48, 57, 65, 90, 97, 
	122, 0
]

class << self
	attr_accessor :_irc_single_lengths
	private :_irc_single_lengths, :_irc_single_lengths=
end
self._irc_single_lengths = [
	0, 1, 0, 0, 2, 1, 5, 4, 
	5, 4, 5, 4, 5, 4, 5, 4, 
	5, 4, 5, 4, 5, 4, 5, 4, 
	5, 4, 5, 4, 5, 4, 5, 4, 
	5, 4, 4, 3, 3, 3, 3, 3, 
	2, 1, 0, 2, 2, 1, 1, 2, 
	5, 5, 5, 2, 1, 2, 1, 1, 
	2, 3, 2, 3, 0, 1, 0, 1, 
	0, 1, 0, 1, 0, 1, 0, 1, 
	0, 1, 1, 1, 1, 1, 1, 1, 
	1, 1, 3, 1, 0, 2, 0, 1, 
	0, 1, 0, 1, 1, 1, 1, 1, 
	1, 1, 2, 2, 3, 3, 3, 5, 
	5, 5, 5, 5, 5, 5, 5, 5, 
	5, 5, 5, 5, 5, 3, 2, 5, 
	5, 5, 5, 5, 5, 5, 5, 5, 
	5, 5, 5, 5, 5, 5, 4, 0
]

class << self
	attr_accessor :_irc_range_lengths
	private :_irc_range_lengths, :_irc_range_lengths=
end
self._irc_range_lengths = [
	0, 3, 1, 1, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	5, 1, 3, 2, 3, 1, 3, 4, 
	2, 0, 0, 5, 1, 3, 1, 3, 
	4, 6, 4, 6, 3, 3, 3, 3, 
	3, 3, 3, 3, 3, 3, 3, 3, 
	3, 3, 3, 3, 3, 3, 3, 3, 
	3, 3, 3, 3, 3, 3, 1, 1, 
	1, 1, 1, 1, 1, 0, 1, 0, 
	1, 0, 3, 3, 3, 3, 3, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 0, 4, 6, 
	6, 6, 6, 6, 6, 6, 6, 6, 
	6, 6, 6, 6, 6, 6, 4, 0
]

class << self
	attr_accessor :_irc_index_offsets
	private :_irc_index_offsets, :_irc_index_offsets=
end
self._irc_index_offsets = [
	0, 0, 5, 7, 9, 12, 14, 20, 
	25, 31, 36, 42, 47, 53, 58, 64, 
	69, 75, 80, 86, 91, 97, 102, 108, 
	113, 119, 124, 130, 135, 141, 146, 152, 
	157, 163, 168, 173, 177, 181, 185, 189, 
	193, 201, 204, 208, 213, 219, 222, 227, 
	234, 242, 248, 254, 262, 265, 271, 274, 
	279, 286, 296, 303, 313, 317, 322, 326, 
	331, 335, 340, 344, 349, 353, 358, 362, 
	367, 371, 376, 381, 386, 391, 396, 401, 
	406, 411, 416, 423, 428, 432, 438, 440, 
	443, 445, 448, 450, 453, 456, 458, 461, 
	463, 466, 468, 474, 480, 487, 494, 501, 
	509, 517, 525, 533, 541, 549, 557, 565, 
	573, 581, 589, 597, 605, 613, 617, 624, 
	636, 648, 660, 672, 684, 696, 708, 720, 
	732, 744, 756, 768, 780, 792, 804, 813
]

class << self
	attr_accessor :_irc_indicies
	private :_irc_indicies, :_irc_indicies=
end
self._irc_indicies = [
	2, 0, 3, 3, 1, 4, 1, 5, 
	1, 6, 7, 1, 8, 1, 1, 1, 
	1, 1, 10, 9, 1, 1, 12, 13, 
	11, 1, 1, 1, 1, 10, 14, 1, 
	1, 12, 16, 15, 1, 1, 1, 1, 
	10, 17, 1, 1, 12, 19, 18, 1, 
	1, 1, 1, 10, 20, 1, 1, 12, 
	22, 21, 1, 1, 1, 1, 10, 23, 
	1, 1, 12, 25, 24, 1, 1, 1, 
	1, 10, 26, 1, 1, 12, 28, 27, 
	1, 1, 1, 1, 10, 29, 1, 1, 
	12, 31, 30, 1, 1, 1, 1, 10, 
	32, 1, 1, 12, 34, 33, 1, 1, 
	1, 1, 10, 35, 1, 1, 12, 37, 
	36, 1, 1, 1, 1, 10, 38, 1, 
	1, 12, 40, 39, 1, 1, 1, 1, 
	10, 41, 1, 1, 12, 43, 42, 1, 
	1, 1, 1, 10, 44, 1, 1, 12, 
	46, 45, 1, 1, 1, 1, 10, 47, 
	1, 1, 12, 49, 48, 1, 1, 1, 
	1, 10, 50, 1, 1, 52, 53, 51, 
	1, 1, 55, 56, 54, 1, 1, 58, 
	57, 1, 1, 60, 59, 1, 1, 52, 
	61, 1, 1, 63, 62, 1, 1, 12, 
	64, 65, 66, 67, 68, 66, 68, 66, 
	1, 69, 70, 1, 0, 3, 3, 1, 
	6, 7, 71, 71, 1, 69, 72, 73, 
	73, 73, 1, 69, 74, 1, 72, 73, 
	73, 73, 1, 69, 73, 74, 73, 73, 
	73, 1, 75, 76, 77, 77, 78, 77, 
	77, 1, 1, 1, 1, 1, 1, 79, 
	1, 1, 1, 1, 78, 79, 80, 81, 
	82, 82, 83, 82, 83, 1, 75, 84, 
	1, 75, 85, 86, 86, 86, 1, 75, 
	87, 1, 85, 86, 86, 86, 1, 75, 
	86, 87, 86, 86, 86, 1, 75, 83, 
	88, 84, 82, 82, 83, 82, 83, 1, 
	75, 83, 84, 83, 83, 83, 1, 75, 
	83, 89, 84, 82, 82, 83, 82, 83, 
	1, 90, 90, 90, 1, 91, 90, 90, 
	90, 1, 92, 92, 92, 1, 93, 92, 
	92, 92, 1, 94, 94, 94, 1, 95, 
	94, 94, 94, 1, 96, 96, 96, 1, 
	97, 96, 96, 96, 1, 98, 98, 98, 
	1, 99, 98, 98, 98, 1, 100, 100, 
	100, 1, 101, 100, 100, 100, 1, 102, 
	102, 102, 1, 75, 102, 102, 102, 1, 
	103, 90, 90, 90, 1, 104, 90, 90, 
	90, 1, 105, 92, 92, 92, 1, 106, 
	92, 92, 92, 1, 107, 94, 94, 94, 
	1, 108, 94, 94, 94, 1, 109, 96, 
	96, 96, 1, 110, 96, 96, 96, 1, 
	111, 112, 112, 98, 98, 98, 1, 113, 
	98, 98, 98, 1, 114, 100, 100, 1, 
	115, 101, 116, 100, 100, 1, 117, 1, 
	118, 119, 1, 120, 1, 121, 122, 1, 
	123, 1, 75, 124, 1, 75, 125, 1, 
	75, 1, 121, 126, 1, 121, 1, 118, 
	127, 1, 118, 1, 115, 101, 128, 100, 
	100, 1, 115, 101, 100, 100, 100, 1, 
	99, 129, 129, 98, 98, 98, 1, 99, 
	130, 130, 98, 98, 98, 1, 99, 111, 
	111, 98, 98, 98, 1, 75, 76, 131, 
	131, 78, 131, 131, 1, 75, 76, 132, 
	132, 78, 132, 132, 1, 75, 76, 133, 
	133, 78, 133, 133, 1, 75, 76, 134, 
	134, 78, 134, 134, 1, 75, 76, 135, 
	135, 78, 135, 135, 1, 75, 76, 136, 
	136, 78, 136, 136, 1, 75, 76, 137, 
	137, 78, 137, 137, 1, 75, 76, 138, 
	138, 78, 138, 138, 1, 75, 76, 139, 
	139, 78, 139, 139, 1, 75, 76, 140, 
	140, 78, 140, 140, 1, 75, 76, 141, 
	141, 78, 141, 141, 1, 75, 76, 142, 
	142, 78, 142, 142, 1, 75, 76, 143, 
	143, 78, 143, 143, 1, 75, 76, 144, 
	144, 78, 144, 144, 1, 75, 76, 78, 
	1, 69, 145, 70, 145, 145, 145, 1, 
	146, 76, 77, 147, 78, 70, 147, 147, 
	77, 147, 77, 1, 146, 76, 131, 148, 
	78, 70, 148, 148, 131, 148, 131, 1, 
	146, 76, 132, 149, 78, 70, 149, 149, 
	132, 149, 132, 1, 146, 76, 133, 150, 
	78, 70, 150, 150, 133, 150, 133, 1, 
	146, 76, 134, 151, 78, 70, 151, 151, 
	134, 151, 134, 1, 146, 76, 135, 152, 
	78, 70, 152, 152, 135, 152, 135, 1, 
	146, 76, 136, 153, 78, 70, 153, 153, 
	136, 153, 136, 1, 146, 76, 137, 154, 
	78, 70, 154, 154, 137, 154, 137, 1, 
	146, 76, 138, 155, 78, 70, 155, 155, 
	138, 155, 138, 1, 146, 76, 139, 156, 
	78, 70, 156, 156, 139, 156, 139, 1, 
	146, 76, 140, 157, 78, 70, 157, 157, 
	140, 157, 140, 1, 146, 76, 141, 158, 
	78, 70, 158, 158, 141, 158, 141, 1, 
	146, 76, 142, 159, 78, 70, 159, 159, 
	142, 159, 142, 1, 146, 76, 143, 160, 
	78, 70, 160, 160, 143, 160, 143, 1, 
	146, 76, 144, 161, 78, 70, 161, 161, 
	144, 161, 144, 1, 146, 76, 145, 78, 
	70, 145, 145, 145, 1, 1, 0
]

class << self
	attr_accessor :_irc_trans_targs
	private :_irc_trans_targs, :_irc_trans_targs=
end
self._irc_trans_targs = [
	2, 0, 40, 43, 3, 4, 5, 6, 
	135, 7, 38, 7, 5, 8, 9, 9, 
	10, 11, 11, 12, 13, 13, 14, 15, 
	15, 16, 17, 17, 18, 19, 19, 20, 
	21, 21, 22, 23, 23, 24, 25, 25, 
	26, 27, 27, 28, 29, 29, 30, 31, 
	31, 32, 33, 33, 5, 34, 35, 5, 
	36, 35, 5, 37, 5, 37, 39, 5, 
	39, 41, 48, 118, 119, 42, 44, 43, 
	45, 47, 46, 42, 49, 103, 51, 50, 
	52, 57, 59, 58, 53, 54, 56, 55, 
	74, 60, 61, 62, 63, 64, 65, 66, 
	67, 68, 69, 70, 71, 72, 73, 75, 
	76, 77, 78, 79, 80, 81, 82, 83, 
	100, 84, 85, 86, 98, 87, 88, 96, 
	89, 90, 94, 91, 92, 93, 95, 97, 
	99, 101, 102, 104, 105, 106, 107, 108, 
	109, 110, 111, 112, 113, 114, 115, 116, 
	117, 118, 42, 120, 121, 122, 123, 124, 
	125, 126, 127, 128, 129, 130, 131, 132, 
	133, 134
]

class << self
	attr_accessor :_irc_trans_actions
	private :_irc_trans_actions, :_irc_trans_actions=
end
self._irc_trans_actions = [
	33, 0, 0, 33, 13, 13, 55, 51, 
	0, 81, 15, 67, 17, 15, 81, 67, 
	15, 81, 67, 15, 81, 67, 15, 81, 
	67, 15, 81, 67, 15, 81, 67, 15, 
	81, 67, 15, 81, 67, 15, 81, 67, 
	15, 81, 67, 15, 81, 67, 15, 81, 
	67, 15, 81, 67, 48, 15, 63, 39, 
	63, 45, 19, 81, 76, 67, 59, 36, 
	42, 21, 30, 21, 71, 3, 1, 13, 
	1, 1, 1, 11, 0, 5, 0, 7, 
	9, 9, 9, 9, 9, 9, 9, 9, 
	9, 9, 9, 9, 9, 9, 9, 9, 
	9, 9, 9, 9, 9, 9, 9, 9, 
	9, 9, 9, 9, 9, 9, 9, 9, 
	9, 9, 9, 9, 9, 9, 9, 9, 
	9, 9, 9, 9, 9, 9, 9, 9, 
	9, 9, 9, 5, 5, 5, 5, 5, 
	5, 5, 5, 5, 5, 5, 5, 5, 
	5, 1, 27, 24, 24, 24, 24, 24, 
	24, 24, 24, 24, 24, 24, 24, 24, 
	24, 24
]

class << self
	attr_accessor :irc_start
end
self.irc_start = 1;
class << self
	attr_accessor :irc_first_final
end
self.irc_first_final = 135;
class << self
	attr_accessor :irc_error
end
self.irc_error = 0;

class << self
	attr_accessor :irc_en_main
end
self.irc_en_main = 1;

# line 114 "lib/marvin/parsers/ragel_parser.rl"
      
      private
      
      def self.parse!(line)
        data = "#{line.strip}\r\n"

        p = 0;
        pe = data.length
        cs = 0

        hostmask = nil
        server   = nil
        code     = nil
        command  = Marvin::Parsers::Command.new(data)

        
# line 462 "lib/marvin/parsers/ragel_parser.rb"
begin
	p ||= 0
	pe ||= data.length
	cs = irc_start
end
# line 137 "lib/marvin/parsers/ragel_parser.rl"
        
# line 470 "lib/marvin/parsers/ragel_parser.rb"
begin
	_klen, _trans, _keys, _acts, _nacts = nil
	_goto_level = 0
	_resume = 10
	_eof_trans = 15
	_again = 20
	_test_eof = 30
	_out = 40
	while true
	_trigger_goto = false
	if _goto_level <= 0
	if p == pe
		_goto_level = _test_eof
		next
	end
	if cs == 0
		_goto_level = _out
		next
	end
	end
	if _goto_level <= _resume
	_keys = _irc_key_offsets[cs]
	_trans = _irc_index_offsets[cs]
	_klen = _irc_single_lengths[cs]
	_break_match = false
	
	begin
	  if _klen > 0
	     _lower = _keys
	     _upper = _keys + _klen - 1

	     loop do
	        break if _upper < _lower
	        _mid = _lower + ( (_upper - _lower) >> 1 )

	        if data[p] < _irc_trans_keys[_mid]
	           _upper = _mid - 1
	        elsif data[p] > _irc_trans_keys[_mid]
	           _lower = _mid + 1
	        else
	           _trans += (_mid - _keys)
	           _break_match = true
	           break
	        end
	     end # loop
	     break if _break_match
	     _keys += _klen
	     _trans += _klen
	  end
	  _klen = _irc_range_lengths[cs]
	  if _klen > 0
	     _lower = _keys
	     _upper = _keys + (_klen << 1) - 2
	     loop do
	        break if _upper < _lower
	        _mid = _lower + (((_upper-_lower) >> 1) & ~1)
	        if data[p] < _irc_trans_keys[_mid]
	          _upper = _mid - 2
	        elsif data[p] > _irc_trans_keys[_mid+1]
	          _lower = _mid + 2
	        else
	          _trans += ((_mid - _keys) >> 1)
	          _break_match = true
	          break
	        end
	     end # loop
	     break if _break_match
	     _trans += _klen
	  end
	end while false
	_trans = _irc_indicies[_trans]
	cs = _irc_trans_targs[_trans]
	if _irc_trans_actions[_trans] != 0
		_acts = _irc_trans_actions[_trans]
		_nacts = _irc_actions[_acts]
		_acts += 1
		while _nacts > 0
			_nacts -= 1
			_acts += 1
			case _irc_actions[_acts - 1]
when 0 then
# line 4 "lib/marvin/parsers/ragel_parser.rl"
		begin

    server = Marvin::Parsers::Prefixes::Server.new
  		end
# line 4 "lib/marvin/parsers/ragel_parser.rl"
when 1 then
# line 8 "lib/marvin/parsers/ragel_parser.rl"
		begin

    server.name << data[p]
  		end
# line 8 "lib/marvin/parsers/ragel_parser.rl"
when 2 then
# line 12 "lib/marvin/parsers/ragel_parser.rl"
		begin

    command.prefix = server
  		end
# line 12 "lib/marvin/parsers/ragel_parser.rl"
when 3 then
# line 16 "lib/marvin/parsers/ragel_parser.rl"
		begin

    hostmask =  Marvin::Parsers::Prefixes::HostMask.new
  		end
# line 16 "lib/marvin/parsers/ragel_parser.rl"
when 4 then
# line 20 "lib/marvin/parsers/ragel_parser.rl"
		begin

    hostmask.nickname << data[p]
  		end
# line 20 "lib/marvin/parsers/ragel_parser.rl"
when 5 then
# line 24 "lib/marvin/parsers/ragel_parser.rl"
		begin

    hostmask.user << data[p]
  		end
# line 24 "lib/marvin/parsers/ragel_parser.rl"
when 6 then
# line 28 "lib/marvin/parsers/ragel_parser.rl"
		begin

    hostmask.host << data[p]
  		end
# line 28 "lib/marvin/parsers/ragel_parser.rl"
when 7 then
# line 32 "lib/marvin/parsers/ragel_parser.rl"
		begin

    command.prefix = hostmask
  		end
# line 32 "lib/marvin/parsers/ragel_parser.rl"
when 8 then
# line 36 "lib/marvin/parsers/ragel_parser.rl"
		begin

    code = ""
  		end
# line 36 "lib/marvin/parsers/ragel_parser.rl"
when 9 then
# line 40 "lib/marvin/parsers/ragel_parser.rl"
		begin

    code << data[p]
  		end
# line 40 "lib/marvin/parsers/ragel_parser.rl"
when 10 then
# line 44 "lib/marvin/parsers/ragel_parser.rl"
		begin

    command.code = code
  		end
# line 44 "lib/marvin/parsers/ragel_parser.rl"
when 11 then
# line 48 "lib/marvin/parsers/ragel_parser.rl"
		begin

    params_1 = []
    params_2 = []
  		end
# line 48 "lib/marvin/parsers/ragel_parser.rl"
when 12 then
# line 53 "lib/marvin/parsers/ragel_parser.rl"
		begin

  		end
# line 53 "lib/marvin/parsers/ragel_parser.rl"
when 13 then
# line 56 "lib/marvin/parsers/ragel_parser.rl"
		begin

    params_1 << ""
  		end
# line 56 "lib/marvin/parsers/ragel_parser.rl"
when 14 then
# line 60 "lib/marvin/parsers/ragel_parser.rl"
		begin

    params_2 << ""
  		end
# line 60 "lib/marvin/parsers/ragel_parser.rl"
when 15 then
# line 64 "lib/marvin/parsers/ragel_parser.rl"
		begin

    params_1.last << data[p]
  		end
# line 64 "lib/marvin/parsers/ragel_parser.rl"
when 16 then
# line 68 "lib/marvin/parsers/ragel_parser.rl"
		begin

    params_2.last << data[p]
  		end
# line 68 "lib/marvin/parsers/ragel_parser.rl"
when 17 then
# line 72 "lib/marvin/parsers/ragel_parser.rl"
		begin

    command.params = params_1
  		end
# line 72 "lib/marvin/parsers/ragel_parser.rl"
when 18 then
# line 76 "lib/marvin/parsers/ragel_parser.rl"
		begin

    command.params = params_2
  		end
# line 76 "lib/marvin/parsers/ragel_parser.rl"
# line 684 "lib/marvin/parsers/ragel_parser.rb"
			end # action switch
		end
	end
	if _trigger_goto
		next
	end
	end
	if _goto_level <= _again
	if cs == 0
		_goto_level = _out
		next
	end
	p += 1
	if p != pe
		_goto_level = _resume
		next
	end
	end
	if _goto_level <= _test_eof
	end
	if _goto_level <= _out
		break
	end
	end
	end
# line 138 "lib/marvin/parsers/ragel_parser.rl"

        if cs >= irc_first_final
          command
        else
          raise UnparseableMessage, "Failed to parse the message: #{input.inspect}"
        end
      end
      
    end
  end
end
