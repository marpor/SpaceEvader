extends Node

var meteors = [
	[ 30, preload("res://enemies/Meteor1.tscn")],
	[ 30, preload("res://enemies/Meteor2.tscn")],
	[ 20, preload("res://enemies/Meteor3.tscn")],
	[ 20, preload("res://enemies/Meteor4.tscn")],
	[ 10, preload("res://enemies/Meteor5.tscn")],
]

func makeInstance():
	return Helpers.pickWeighted(meteors).instance()
