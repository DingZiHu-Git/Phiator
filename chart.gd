extends HBoxContainer

var info: Dictionary
func init(dictionary: Dictionary) -> void:
	info = dictionary
	$Illustration.texture = ImageTexture.create_from_image(Image.load_from_file(Global.DIR + info["path"] + Global.SEPARATOR + info["illustration"]))
	$Info/Chart.text = info["chart"]
	$Info/Description.text = tr("chart_artist") + info["artist"] + "\n" + tr("chart_level") + (info["level"] if info.has("level") else info["version"]) + "\n" + tr("chart_author") + info["author"] + "\n" + tr("chart_last_edit") + String.num_uint64(info["lastEdit"])
