.open /home/ben/Downloads/stash-go.sqlite
select folders.path || '/' || files.basename as path from performers, performers_scenes, scenes, files, scenes_files, folders
	where performers.name like '%Alex Coal%' AND
		performers_scenes.performer_id = performers.id AND
		scenes.id = performers_scenes.scene_id  AND
		scenes_files.scene_id = scenes.id AND
		files.id = scenes_files.file_id AND
		folders.id = files.parent_folder_id