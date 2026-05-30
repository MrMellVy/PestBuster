extends Node

var gameStarted: bool

var playerBody: CharacterBody2D

var playerDamageAmount: int
var playerDamageZone: Area2D
var playerAlive: bool
var playerHitbox: Area2D

var EnemyDamageZone: Area2D
var EnemyDamageAmount: int

var current_wave: int
var moving_to_next_wave: bool

var high_score = 0
var current_score: int
var previous_score: int
