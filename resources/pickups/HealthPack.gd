extends Pickup
class_name HealthPack

var heal_amount: int = 100

func can_be_collected(player: Player) -> bool:
	return player.get_missing_health() > 0

func collect(player: Player) -> bool:
	if can_be_collected(player):
		player.heal_damage(min(heal_amount, player.get_missing_health()))
		play_sfx(player)
		return true
	return false
