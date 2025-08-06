import os

def find_related_media(filepath):
    """
    Given a path to a metadata file (like .srt, .nfo, .edl),
    finds the corresponding primary media file (.mkv, .mp4, etc.).

    This is a more robust Python replacement for the logic in shell
    functions like `get__subtitle_related_media` and `get_audio_file`.

    Args:
        filepath (str): The full path to the metadata file.

    Returns:
        str or None: The full path to the media file if found, otherwise None.
    """
    if not filepath or not os.path.isdir(os.path.dirname(filepath)):
        return None

    # Common video and audio extensions, ordered by likelihood
    MEDIA_EXTENSIONS = [
        '.mkv', '.mp4', '.webm', '.avi', '.wmv', '.mov', # Video
        '.m4a', '.mp3', '.flac', '.wav', '.aac', '.ogg'  # Audio
    ]

    base_path, _ = os.path.splitext(filepath)

    for ext in MEDIA_EXTENSIONS:
        potential_media_file = base_path + ext
        if os.path.exists(potential_media_file):
            return potential_media_file

    return None