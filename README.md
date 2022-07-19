# prores-proxy-generator
Create ProRes Proxies using FFMPEG

## Setup
```
git clone https://github.com/levimake/prores-proxy-generator
cd prores-proxy-generator
chmod +x proxygen.sh
```

## Usage
```
./proxygen.sh [FOLDER_CONTAINING_INPUTS] [PROXY_QUALITY]
```

## Example
```
./proxygen.sh ~/Videos/Footages/ 720p
```

Available resolution formats: 720p, 1080p, 4K

### Requirements
FFMPEG, pv

(Mac users: brew install ffmpeg pv)

