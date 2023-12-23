import ffmpeg
(
    ffmpeg
    .input('$IMGSRC/cleanfillets/*.jpg', pattern_type='glob', framerate=25, filter='scale=1920:1080,format=yuv420p')
    .output('movie.mp4')
    .run()
)