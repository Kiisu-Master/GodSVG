class_name BetterSceneTranslationParser extends EditorTranslationParserPlugin

var collect_tab_names := true

# Properties to include, as wildcards.
var include_properties: PackedStringArray = [
	"text",
	"title",
	"popup/*/text",
	"*_text",
]

var include_types: PackedStringArray = [
	"Control",
	"FileDialog",
]

var exception_list := {
	"LineEdit": ["text"],
	"TextEdit": ["text"],
	"CodeEdit": ["text"],
}


func _get_recognized_extensions() -> PackedStringArray:
	return ["tscn", "scn"]


func _parse_file(path: String, msgids: Array[String], msgids_context_plural: Array[Array]) -> void:
	_parse_packed_scene(ResourceLoader.load(path), msgids, msgids_context_plural)


func _parse_packed_scene(scene: PackedScene, msgids: Array[String], msgids_context_plural: Array[Array]) -> void:
	var state := scene.get_state()
	var tabcontainer_paths := []
	for node in state.get_node_count():
		var type := state.get_node_type(node)
		
		# Handle instanced scenes.
		if type.is_empty():
			var instance := state.get_node_instance(node)
			if instance != null:
				var _state := instance.get_state()
				var _include := true
				for property in _state.get_node_property_count(0):
					if _state.get_node_property_name(0, property) == "auto_translate":
						_include = _state.get_node_property_value(0, property)
						break
				if _include:
					type = state.get_node_instance(node).get_state().get_node_type(0)
		
		# Only take strings from UI nodes.
		var include := false
		for include_type in include_types:
			if ClassDB.is_parent_class(type, include_type):
				include = true
				break
		if not include:
			continue
		
		# Found translatable strings.
		var strings: Array[String] = []
		# If the found strings should be added to the POT / is auto translate on
		var should_include := true
		
		if collect_tab_names:
			if not tabcontainer_paths.is_empty():
				var parent_path := state.get_node_path(node, true)
				if not parent_path.get_concatenated_names().begins_with(tabcontainer_paths[tabcontainer_paths.size() - 1].get_concatenated_names()):
					tabcontainer_paths.pop_back()
				if not tabcontainer_paths.is_empty() and parent_path == tabcontainer_paths[tabcontainer_paths.size() - 1]:
					strings.append(state.get_node_name(node))
			if type == "TabContainer":
				tabcontainer_paths.append(state.get_node_path(node))
		
		for property in state.get_node_property_count(node):
			var prop_name := state.get_node_property_name(node, property)
			var prop_val := state.get_node_property_value(node, property)
			if prop_name == "auto_translate" and not prop_val:
				should_include = false
				break
			elif _match_property(type, prop_name):
				strings.append(prop_val)
		
		if should_include:
			msgids.append_array(strings)


func _match_property(type, prop_name: String) -> bool:
	if exception_list.has(type):
		for prop in exception_list[type]:
			if prop_name.match(prop):
				return false
	for prop in include_properties:
		if prop_name.match(prop):
			return true
	return false
