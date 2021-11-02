extends Node

var enemies = [
	[ 50, preload("res://enemies/Enemy1.tscn")],
	[ 25, preload("res://enemies/Enemy2.tscn")],
	[ 15, preload("res://enemies/Enemy3.tscn")],
	[  2, preload("res://enemies/Boss1.tscn")],
	[  5, preload("res://enemies/Boss2.tscn")],
	[  2, preload("res://enemies/Boss3.tscn")],
	[  2, preload("res://enemies/Boss4.tscn")],
	[  2, preload("res://enemies/Boss5.tscn")],
	[  6, preload("res://enemies/Boss6.tscn")],
]

func makeInstance():
	return Helpers.pickWeighted(enemies).instance()
