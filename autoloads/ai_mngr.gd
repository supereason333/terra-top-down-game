extends Node

var agents:Array[EntityAI]

func _ready() -> void:
	var update_timer := Timer.new()
	update_timer.wait_time = 0.1
	update_timer.autostart = true
	update_timer.one_shot = false
	update_timer.timeout.connect(update)
	update_timer.name = "UpdateTimer"
	add_child(update_timer)

func register(agent:EntityAI):
	agents.append(agent)
	agent.tree_exiting.connect(on_agent_exiting_tree.bind(agent))

func remove(agent:EntityAI):
	agents.erase(agent)
	agent.tree_exiting.disconnect(on_agent_exiting_tree)

func on_agent_exiting_tree(agent:EntityAI):
	agents.erase(agent)
	agent.tree_exiting.disconnect(on_agent_exiting_tree)

func update():
	for agent in agents:
		agent._ai_update()
