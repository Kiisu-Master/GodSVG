@tool
extends EditorPlugin

var scene_parser_plugin := BetterSceneTranslationParser.new()
var gdscript_parser_plugin := BetterGDSCriptTranslationParser.new()

func _enter_tree() -> void:
	add_translation_parser_plugin(scene_parser_plugin)
	add_translation_parser_plugin(gdscript_parser_plugin)

func _exit_tree() -> void:
	remove_translation_parser_plugin(scene_parser_plugin)
	remove_translation_parser_plugin(gdscript_parser_plugin)
