.open /home/ben/Downloads/stash-go.sqlite
select folders.path || '/' || files.basename as path from tags, scenes_tags, scenes, files, scenes_files, folders
	where tags.name like '%Solid Gold%' AND
		scenes_tags.tag_id = tags.id AND
		scenes.id = scenes_tags.scene_id AND
		scenes_files.scene_id = scenes.id AND
		files.id = scenes_files.file_id AND
		folders.id = files.parent_folder_id
		
		
