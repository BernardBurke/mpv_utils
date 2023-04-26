import requests

import re

import sys

import os


headers = {

    "Referer": "https://www.whyp.it/",

}



def get_audio_name(url: str) -> str:

    resp = requests.get(url).content.decode("utf8")

    return re.search(r"\w{8}-\w{4}-\w{4}-\w{4}-\w{12}.mp3", resp).group()



def download_file(url_name: str, filename: str):

    req = requests.get(f"https://cdn.whyp.it/{url_name}", headers=headers, stream=True)

    with open(filename, "wb") as f:
        print(f"Downloading {url_name}")
        for chunk in req.iter_content(chunk_size=1024):
            #print(f"Downloading {url_name} chunk {chunk} bytes")
            f.write(chunk)



if __name__ == "__main__":
    
    input_file = sys.argv[1]
    
    file = open(input_file, 'r')
    
    while True:
        record = file.readline()
        if not record:
            break
        #print(record)
        if "?" in record:
            chunky = record.split("?")
        else:
            chunky = record.split('\n')
            
        #print(chunky[0])
        title = chunky[0].rsplit('/',1)[-1]
        print(f" Title is {title} on chunky {chunky[0]}")
        if not os.path.exists(title + ".mp3"):
            Burlname = get_audio_name(record)
            print(f"Burlname is {Burlname}")
#        download_file(chunky[0],title + ".mp3")   
            print(f"Downloading {record}")
            download_file(Burlname ,title + ".mp3")   
        else:
            print(f"{title} already exists")
            
    #sys.exit()

    #audio_name = get_audio_name(sys.argv[1])

    #download_file(audio_name)
