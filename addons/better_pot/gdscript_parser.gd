class_name BetterGDSCriptTranslationParser extends EditorTranslationParserPlugin

func _get_recognized_extensions() -> PackedStringArray:
	return ["gd"]

func _parse_file(path: String, msgids: Array[String], msgids_context_plural: Array[Array]) -> void:
	var source := FileAccess.get_file_as_string(path)
	
	var regex := RegEx.new()
	regex.compile('(?<=(tr\\(&"))(((?<!"\\)).)*)(?=("\\)))')
	var results := regex.search_all(source)
	for result in results:
		msgids.append(result.strings[0].c_unescape())
