.open /home/ben/.stash/stash-go.sqlite
select folders.path || '/' || files.basename as path from performers, performers_scenes, scenes, files, scenes_files, folders
	where performers.birthdate  > '1993-01-01' AND
		performers_scenes.performer_id = performers.id AND
		performers.birthdate is not null AND
		scenes.id = performers_scenes.scene_id  AND
		scenes_files.scene_id = scenes.id AND
		files.id = scenes_files.file_id AND
		folders.id = files.parent_folder_id
