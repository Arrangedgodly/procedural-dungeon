extends CharacterBody2D
class_name Player

@export var sprite: AnimatedSprite2D
@export var collision_shape: CollisionShape2D

var health: int = 50
var speed: int = 200
var basic_damage: int = 5
