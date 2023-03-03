.open /home/ben/.stash/stash-go.sqlite
select folders.path || '/' || files.basename as path from  scenes, files, scenes_files, folders, studios
	where studios.name like '%Mommy%' AND
		studios.id = scenes.studio_id AND
		scenes_files.scene_id = scenes.id AND
		files.id = scenes_files.file_id AND
		folders.id = files.parent_folder_id